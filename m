From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 9 Jun 2009 05:49:07 +0000
Message-ID: <20090609054907.GA4106@ff.dom.local>
References: <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net> <20090603095412.GC5644@ff.dom.local> <298f5c050906040650y31de6fdcv865e775d52bc977c@mail.gmail.com> <20090604193013.GA2755@ami.dom.local> <4A282216.20203@trash.net> <20090604194203.GB2755@ami.dom.local> <4A2DF25C.7030109@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:61318 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbZFIF5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 01:57:06 -0400
Received: by ewy6 with SMTP id 6so4842304ewy.37
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2009 22:57:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A2DF25C.7030109@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 09:25:48AM +0400, Badalian Vyacheslav wrote:
> Hello!
> Do you have any progress to apply this patch set?
> I'm very interested to view that patches in mainline kernel tree. We
> would like to use HTB for speeds more than 1G (converts 10 servers x 1G
> to few with 10G intel multi queue network devices).

Hi,

I'll try to send patches today, but they are expected to work with 1G
or maybe a little more. I'm not sure higher rates make sense without
tso/gso, which isn't properly handled by packet schedulers anyway, so
more time/feedback/testing will be needed to go further.

Regards,
Jarek P.
