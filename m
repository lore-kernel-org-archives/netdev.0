From: dmpesl <dmpesl@ldis.cs.msu.su>
Subject: Re: FWD: 2.4.35 e1000 problems
Date: Mon, 15 Oct 2007 18:25:56 +0400 (MSD)
Message-ID: <Pine.BSO.4.61.0710151820370.17424@ldisi.cs.msu.su>
References: <20071015135917.GA9608@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ldis.cs.msu.su ([158.250.10.196]:36293 "EHLO ldis.cs.msu.su"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754084AbXJOOwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:52:31 -0400
In-Reply-To: <20071015135917.GA9608@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again
I can only test it, if i can compile it statically in kernel, but as i've 
seen that is not possible.
That server is not completely owned by me, i'm just helping to solve some 
hardware and software related problems. And i think if there will be any 
problems during testing... owner/web admin of server will not be glad :)
Maybe couple of reboots... And i can not migrate to 2.6 in easy way 
because of old glibc/gcc.

On Mon, 15 Oct 2007, Willy Tarreau wrote:

> Hi,
>
> Dmitry, I've forwarded your mail to the netdev mailing list and to
> the e1000 maintainers.
>
> Auke, does it sound like a known problem ? Maybe someone has seen it
> in 2.6 ? Just for the record, e1000 in 2.4.35 is 7.3.20-k4.
>
> Dmitry, if you have time for a test, I think it would be good if you
> could test the most recent driver from e1000.sf.net. It might give
> us some more information about the problem's cause. Otherwise, let's
> wait for Auke's advices and/or questions.
>
> Regards,
> Willy
>
> ----- Forwarded message from dmpesl <dmpesl@ldis.cs.msu.su> -----
>
> Date: Mon, 15 Oct 2007 17:54:01 +0400 (MSD)
> From: dmpesl <dmpesl@ldis.cs.msu.su>
> Subject: 2.4.35 e1000 problems
> To: w@1wt.eu
> X-X-Sender: dmpesl@ldisi.cs.msu.su
>
> Hello, Willy
>
> on recent month i've changed kernel from 2.4.31->2.4.35 on my Owl-based
> web server (purchased SATA hdd, onboard SATA 20378), Asus PCH-DR mb,
> 2*Xeon, and noticed that following error occurs on network card:
> ---------------------------------------------
> Sep 29 21:29:51 host kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 29 21:29:53 host kernel: e1000: eth0: e1000_watchdog: NIC Link is Up
> 100 Mbps Full Duplex, Flow Control: RX/TX
> Sep 29 22:28:03 host kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 29 22:28:05 host kernel: e1000: eth0: e1000_watchdog: NIC Link is Up
> 100 Mbps Full Duplex, Flow Control: RX/TX
> Sep 30 00:51:35 host kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 30 00:51:37 host kernel: e1000: eth0: e1000_watchdog: NIC Link is Up
> 100 Mbps Full Duplex, Flow Control: RX/TX
> ---------------------------------------------
> After some conversation with my collocation provider (changing cables and
> switch port) i've searched google to same errors and found some advises to
> use ethtool -k tso off, but this is not work with my kernel/distribution.
> Then i swapped just e1000 driver in 2.4.35 to older, from 2.4.31.
> Now everything works, without loosing link.
>
> Regards, Dmitry
>
> ----- End forwarded message -----
>
