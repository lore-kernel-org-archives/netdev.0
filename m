From: jamal <hadi@cyberus.ca>
Subject: Re: traffic shaping with NAT: IFB as IMQ replacement?
Date: Fri, 30 Mar 2007 08:33:26 -0400
Message-ID: <1175258006.4879.5.camel@localhost>
References: <m27it09n5w.fsf@quark.karme-net.hirschau>
	 <1175184716.4881.30.camel@localhost>  <200703300108.01994.gerd@egidy.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jens Thiele <karme@berlios.de>, netdev@vger.kernel.org,
	linuximq@yahoogroups.com
To: "Gerd v. Egidy" <gerd@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:21987 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbXC3Mdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 08:33:32 -0400
Received: by wx-out-0506.google.com with SMTP id h31so511239wxd
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2007 05:33:32 -0700 (PDT)
In-Reply-To: <200703300108.01994.gerd@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-30-03 at 01:08 +0200, Gerd v. Egidy wrote:

> I'm also interested in shaping NAT. Would you mind telling us what you have in 
> mind with your userspace code? Do you plan something like
> 
> tun -> your userspace code -> tun
>              ^
>              | (netlink)
>              v
>           conntrack
> 

Conntrack is already a perfomance hog - so using user space in that
manner is sinful. The idea is to use contrack netlink to setup tc
rules with ifb. 
In any case, if you are interested talk to me privately;
i have received a few emails since i posted but mostly for people who
want to test.  If you are in that category please just keep pinging me
and i will feel guilty and get it done.

cheers,
jamal

