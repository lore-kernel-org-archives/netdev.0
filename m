From: danylux79 <danilo.toschi@gmail.com>
Subject: Re: network failures w. r8169 (RTL8111/RTL8168B)
Date: Mon, 18 Jan 2010 05:15:16 -0800 (PST)
Message-ID: <27210317.post@talk.nabble.com>
References: <20070115143857.GA2666@lida5.home.bcs>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kuber.nabble.com ([216.139.236.158]:59181 "EHLO
	kuber.nabble.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab0ARNPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 08:15:18 -0500
Received: from isper.nabble.com ([192.168.236.156])
	by kuber.nabble.com with esmtp (Exim 4.63)
	(envelope-from <lists@nabble.com>)
	id 1NWrRs-0000Mq-VT
	for netdev@vger.kernel.org; Mon, 18 Jan 2010 05:15:16 -0800
In-Reply-To: <20070115143857.GA2666@lida5.home.bcs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello, sorry for my bad english :-)
i have your problem, i have buy a jetway n92 330 mini-itx board, this board
have rtl 8111c gbit port.
When i have install endian this port don't work but there is work around.

Plese follow this post : http://efwsupport.com/index.php?topic=1132.0

there is a compiled driver for endian.

you download it, and after follow the step : option 1 or option 2 for
install.

for my the option 2 don't work. but the option 1 work fine...the link is
stable, but there is a problem.
when you go in endian via webgui you don't enter in the menu named state-->
state of the network because there is a various problem --the gui not
responding or the interface go down...
another the sistem don't se the traffic meter for this port. but the other
services work fine for me .

Best regards


Jens Stroebel-2 wrote:
> 
> 
> 				Hello.
> 
> I am trying to get a RTL8111 (RealTek ethernet controller) running w.
> the r8169 kernel module. I am using kernel 2.6.19.2 on a
> LinuxFromScratch system; the motherboard on which said RTL8111 sits is
> an Asus P5B.
> 
> lspci says (regarding the ethernet chip):
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B
> PCI Express Gigabit Ethernet controller (rev 01)
> 
> During the use of network connections, we experience "network transfer
> stops" during which a transfer seems to stall completely for many
> seconds, after which the transfer runs as if nothing happened.
> 
> This is reproducable everytime w. 
>  svn co http://svnserver/svn/tree
>    (hangs VERY LONG)
> 
> and w. LWP::Parallel::UserAgent. With the latter, I fired 100 runs of
> 100 requests, 7 "clients" trying parallel requests.
> Of these 100 runs, at least one, sometimes 2 stall for about 90 secs,
> after which the run continues and ends successfully, although the time
> of more than 90 secs for 100 requests can't be called sucessful, really.
> 
> Both the subversion checkout and the performance testing via
> LWP::Parallel::UserAgent run as expected (-> without stalling somewhere)
> on our other machines which do not have RTL8111.
> They also run as expected with kernels 2.6.18.x and
> the realtek driver r1000.
> 
> With kernel 2.6.19.x, the r1000 driver is unusable as it has enormous
> packet loss (used version: r1000_v1.05.tgz).
> The r8169 SEEMS to have no packet loss (ping, ping -f) but above
> mentioned phenomenon seems to indicate otherwise.
> 
> Has someone experienced similar effects w. r8169.ko and RTL8111?
> (I searched the archives but didn't quite find anything like this)
> 
> I also tried kernel 2.6.20-rc5 to see if the problem eventually went
> away, but unfortunately the scenario remains the same.
> 
> 		Greets,
> 		  Jens
> -- 
> drifter@bcsoft.de
> 			23.....56.......drifting 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

-- 
View this message in context: http://old.nabble.com/network-failures-w.-r8169-%28RTL8111-RTL8168B%29-tp8372599p27210317.html
Sent from the netdev mailing list archive at Nabble.com.

