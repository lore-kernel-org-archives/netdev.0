From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Tue, 03 Apr 2007 21:10:16 -0400
Message-ID: <1175649016.3957.10.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:43388 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719AbXDDBKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 21:10:19 -0400
Received: by wx-out-0506.google.com with SMTP id h31so42101wxd
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2007 18:10:19 -0700 (PDT)
In-Reply-To: <20070404000054.M58020@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 2007-04-04 at 03:03 +0300, Denys wrote:
> I'm not sure it is mistake or error, but i feel it is dangerous, cause 
> commands locking up the system, no kernel panic, no oops, so only watchdog 
> can save poor server (and not sure this even)
> 
> Commands to lockup system (just i am giving my example, i didnt sort out what 
> exactly locked up system, i guess redirecting to eth0.5, which is not 
> intended for that):
> 

read:
doc/actions/mirred-usage

cheers,
jamal


> vconfig add eth0 5
> ifconfig eth0.5 192.168.1.2 netmask 255.255.255.128
> 
> tc qdisc add dev eth0 ingress
> tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
> match ip src 195.69.208.252/32 flowid 1:16 \
> action police rate 64kbit burst 90k pipe \
> action mirred egress mirror dev eth0.5
> 
> --
> Denys Fedoryshchenko
> Technical Manager
> Virtual ISP S.A.L.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

