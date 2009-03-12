From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 19:48:39 +0100
Message-ID: <49B95907.4010404@weinigel.se>
References: <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net> <49B94BCA.6090309@weinigel.se> <20090312180638.GG14491@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:54679 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbZCLSsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 14:48:43 -0400
In-Reply-To: <20090312180638.GG14491@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamie Lokier wrote:
> However there was some attempt to get a reference initrd build into
> the kernel.  Did that go anywhere?  It would actually be good to use
> that if it exists.

That would be a very worthwhile project actually.  Create a package that 
uses klibc, does BOOTP/DCHP/NFS and parses the the ip=foo,bar options 
the same way the kernel does so that we can finally get rid of the in 
kernel stuff.  That, the code that reads an initrd from a floppy disk 
(nobody can really be using that code anymore, can they?), and the md 
setup are probably the last obstacles to doing a nice little cleanup of 
the mount_root code in the kernel.

I just wish I had more time.

   /Christer


