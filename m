From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Wed, 29 Jul 2015 10:51:07 +0200
Message-ID: <1970944.Bv0UlMJzsJ@storm>
References: <1719052.SGOfRAJhfQ@storm> <2239047.Ns2P95dsQ1@storm> <309B89C4C689E141A5FF6A0C5FB2118B78DDC307@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	Yanir Lubetkin <yanirx.lubetkin@intel.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:50951 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbbG2I6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 04:58:17 -0400
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B78DDC307@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff and Yanir,

On Saturday, 30. May 2015 01:18:44 Brown, Aaron F wrote:
> > any news on this from the Intel labs?
> 
> Nothing significant.  Another one of our testers (whom works more closely
> with the current e1000e driver owner than I) has managed to replicate it
> on several systems and I know the developer spent some time poking around
> the setup, but I don't think he's found the root cause yet and has been
> busy chasing a number of other issues.

so, any news from the Intel labs? I've seen some "hang fixes"
on 03.06.2015, but I'm not sure if they are related to this issue.

This problem is pretty annoying: We have a performance penalty for all 
network cards right now as the buffer size of the core network stack
had to be decreased to 4096 bytes again on our side.
(https://www.marc.info/?l=linux-netdev&m=142131668206333)
Better than no e1000e network connectivity though.

The initial report on this issue was on 14.01.2015:
https://www.marc.info/?l=linux-netdev&m=142124954120315

Best regards,
Thomas
