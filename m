From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 0/3] ip netns: Run over all netns
Date: Thu, 8 Jan 2015 02:52:12 +0200
Message-ID: <20150108005212.GA10487@angus-think.lan>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
 <CAHA+R7OpGoYx51DQfLhFiZmU_jMfd28G6kssgft6NQoFXj_X+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:43353 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723AbbAHBCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 20:02:35 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so441527lbd.9
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 17:02:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7OpGoYx51DQfLhFiZmU_jMfd28G6kssgft6NQoFXj_X+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 04:04:14PM -0800, Cong Wang wrote:
> On Wed, Jan 7, 2015 at 3:04 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> >
> > Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.
> >
> > 'ip netns exec' executes command forcely on eacn nsname.
> >
> 
> Why this has to be done in iproute command?
> That is, why not just offloading this to a shell script like below?
> 
> for ns in `ip netns show`;
> do
>      ip netns exec $ns ip link show.....
> done

Hm, but would not it better to have it in iproute instead of collect
scripts ? Scripts allows to do a lot of things, but in this case it seems like a
feature which related to iproute.
