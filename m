From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel crash on htbinit restart
Date: Fri, 13 Feb 2009 22:09:54 +0100
Message-ID: <20090213210954.GC2929@ami.dom.local>
References: <334525CB-A895-4320-BF30-B223652806F8@sevsky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denis Romanenko <ash@sevsky.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:45814 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbZBMVIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 16:08:35 -0500
Received: by bwz5 with SMTP id 5so2014202bwz.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 13:08:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <334525CB-A895-4320-BF30-B223652806F8@sevsky.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2009 at 05:01:21PM +0200, Denis Romanenko wrote:
> Hi all

Hi Denis,

> i have high loaded system - about 1,2 gbps
>
> System is Gentoo, kernel vanilla 2.6.27.10 with htb patch 04 from Jarek. 
> This patch going into mainline kernel 2.6.27.13
>
> Uptime of router is 15 days
> today, after changing shaper paramaters i have a crash on restart script 
> htbinit
> its a standard script from http://sourceforge.net/projects/htbinit/
>
> Unfortunately, i dont have anybody info from netconsole, but router is  
> up after 3 min - I think its a
> softlock panic
>
> Do you hava any idea ?

Sorry, without logs - no idea. In 2.6.27.17 is also a cls_u32 patch.
Otherwise there were nothing critical around this. But it could be
anything else... Maybe try to turn on some/more debugging?

Best regards,
Jarek P.
