From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [linux-nics] e1000e: initialization breaks IPMI support on
 80003ES2LAN
Date: Wed, 17 Feb 2016 21:39:37 +0100
Message-ID: <20160217203937.GA30605@xanadu.blop.info>
References: <20160212155847.GA22910@xanadu.blop.info>
 <87618083B2453E4A8714035B62D6799250577DB7@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"Ertman, David M" <david.m.ertman@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:37249 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965580AbcBQUjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:39:45 -0500
Content-Disposition: inline
In-Reply-To: <87618083B2453E4A8714035B62D6799250577DB7@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Emil,

On 17/02/16 at 19:22 +0000, Tantilov, Emil S wrote:
> >My understanding is that, during driver initialization, e1000e_reset()
> >is called, which calls e1000_power_down_phy(), which breaks the BMC.
> 
> e1000_power_down_phy() is only called in reset if the interface is down.
> If you are not using the interface, then you can blacklist the driver.
> Otherwise bringing up the interface should power the PHY back up and 
> restore the link for the BMC.

We are using the interface. It is not brought back up for the BMC
(or maybe, it is brought back up, but the BMC loses its configuration).
-- 
| Lucas Nussbaum      Assistant professor @ Univ. de Lorraine |
| lucas.nussbaum@loria.fr                     LORIA / MADYNES |
| http://www.loria.fr/~lnussbau/            +33 3 54 95 86 19 |
