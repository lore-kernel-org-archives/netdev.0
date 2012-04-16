From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: [PATCH v2] bonding: start slaves with link down for ARP monitor
Date: Mon, 16 Apr 2012 12:27:13 +0200
Message-ID: <1410525.5tCeY2AOxF@alaris>
References: <20120414220617.DA8BE45BA2@lion.mk-sys.cz> <20120415002153.4c4e152a@asterix.rh> <19180.1334465333@death.nxdomain>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40073 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616Ab2DPK1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 06:27:15 -0400
In-Reply-To: <19180.1334465333@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 14 of April 2012 21:48EN, Jay Vosburgh wrote:
> 	Anybody got a 10 or 100 card laying around with fast autoneg to
> try?  Back in the day I used 3c59x and e100s, and I seem to recall
> that the 3c59x board I had was pretty speedy at going carrier up.
> >Jay? Andy? :)

It seems these cards are hard to find these days (I tried to find one in 
our office but no luck yet). However, I tried an onboard adapter with 
r8169 driver and patched kernel succeeded to detect carrier in time for 
bonding driver to start the slave in "up" state (and it started in 
"down" state with unplugged cable so that the detection is correct).

                                                        Michal Kubecek
