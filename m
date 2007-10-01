From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Sun, 30 Sep 2007 18:59:54 -0700
Message-ID: <4700549A.70409@intel.com>
References: <1191174077.6165.11.camel@localhost>	 <46FFE809.8020504@intel.com>
 <1191178881.6165.40.camel@localhost>	 <46FFF7AD.7090309@garzik.org>
 <1191180669.6165.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:61156 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbXJACAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 22:00:07 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms040.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JP700GKQMVVTLN7@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 30 Sep 2007 20:59:56 -0500 (CDT)
In-reply-to: <1191180669.6165.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2007-30-09 at 15:23 -0400, Jeff Garzik wrote:
> 
>> Gotta wait a bit, otherwise we have confusion and a bit of breakage from 
>> two drivers with the same PCI IDs.
> 
> ah, ok ;-> 
> When i was testing i compiled out e1000. I am willing to totaly migrate
> to e1000e, since major machine i have access to has PCIE. Auke, just let
> me know what you need to do other than uncommenting the table entries
> and i will leave you alone ;->

the IDs are the only thing needed to enable all pci-e e1000 hardware.

by all means we need to have guys like you and Jeff test the commented IDs! I've
been doing this myself and the e1000e driver goes to our labs for a period of
testing from next week. Unfortunately they don't know how to break it that good as
some of you guys ;)

I'll personally try to get an 82571EB tested on monday.

Auke
