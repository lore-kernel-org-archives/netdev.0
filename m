From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH iproute2 0/3] ip netns: Run over all netns
Date: Wed, 7 Jan 2015 16:04:14 -0800
Message-ID: <CAHA+R7OpGoYx51DQfLhFiZmU_jMfd28G6kssgft6NQoFXj_X+A@mail.gmail.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:58336 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbAHAEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 19:04:15 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so1720306qcq.25
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 16:04:14 -0800 (PST)
In-Reply-To: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 3:04 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>
> Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.
>
> 'ip netns exec' executes command forcely on eacn nsname.
>

Why this has to be done in iproute command?
That is, why not just offloading this to a shell script like below?

for ns in `ip netns show`;
do
     ip netns exec $ns ip link show.....
done
