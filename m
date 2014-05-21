From: Cong Wang <cwang@twopensource.com>
Subject: Re: Default network namespace name
Date: Wed, 21 May 2014 09:43:07 -0700
Message-ID: <CAHA+R7NwrV2bQQQ3ZtkBWwoAUX5UmqZLgZz-XJMT5ZMW=MM3Sw@mail.gmail.com>
References: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Peter Fassberg <pf@leissner.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:38235 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaEUQnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 12:43:07 -0400
Received: by mail-qc0-f173.google.com with SMTP id i8so3650369qcq.32
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 09:43:07 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 11:36 PM, Peter Fassberg <pf@leissner.se> wrote:
>
> Hi!
>
> Is there a name of the default network namespace?
>

Network namespace doesn't even have a name in kernel, it's
the user-space (ip netns) who gives a name to it. IOW, you
need to modify ip netns or write your own code.
