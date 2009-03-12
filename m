From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:43:05 +0100
Message-ID: <49B965C9.5090209@weinigel.se>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312192504.GB16611@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:48477 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbZCLTnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:43:10 -0400
In-Reply-To: <20090312192504.GB16611@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamie Lokier wrote:
> In other words, glibc doesn't work on some embedded targets even if
> you have plenty of room: they don't support dynamic libs.

It might be possible to build glibc to always use hosts+DNS for name 
lookup, but since I almost always use uclibc on embedded systems I 
haven't really tried to do it.  If I use glibc, it's on a NFS root and 
those systems are large enough anyway.

>> uclibc also seems to have issues with networking and statically linked 
>> binaries, but I just haven't had time to figure out why yet.
> 
> I've never had an issue with uclibc and networking.

I'm not sure what is happening, but a statically linked uclibc binary 
that does TCP networking will work happily with one userspace but not 
another.  It would seem to me that a statically linked binary should 
only depend on the kernel ABI and not on anything userspace (except the 
text files in /etc like resolv.conf), but that does not seem to match 
reality.  If I use Unix sockets instead it works fine, so belive it is 
something related to TCP.  But well, this is all very fuzzy because I 
haven't had time to look more closely at it yet.

   /Christer
