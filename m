From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: Patchset - Support for configurable RSS hash key
Date: Wed, 5 Feb 2014 12:20:21 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C86E05F@CMEXMB1.ad.emulex.com>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com>
 <20140202161016.GA17000@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:10470 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaBEMUW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 07:20:22 -0500
In-Reply-To: <20140202161016.GA17000@mtl-eit-vdi-22.mtl.labs.mlnx>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Amir Vadai [mailto:amirv.mellanox@gmail.com] On Behalf Of Amir
> Vadai
> Sent: Sunday, February 02, 2014 9:40 PM
> To: Venkata Duvvuru
> Cc: netdev@vger.kernel.org; Ben Hutchings
> Subject: Re: Patchset - Support for configurable RSS hash key
> 
> On 17/01/14 13:02 +0000, Venkata Duvvuru wrote:
> > NIC drivers that support RSS use either a hard-coded value or a random
> value for the RSS hash key. Irrespective of the type of the key used, the user
> would want to change the hash key if he/she is not satisfied with the
> effectiveness of the default hash-key in spreading the incoming flows evenly
> across the RSS queues.
> >
> > This patch set provides support for configuring the RSS hash-key via the
> ethtool interface.
> >
> > The patch set consists of:
> > a) ethtool user-land patches
> > b) ethtool kernel patch
> > c) be2net patch that implements the ethtool hooks
> 
> Hi,
> 
> I would be happy to add support in setting the hash function in addition to
> the hash key.
> 
> Mellanox NIC's have support in 2 hash functions: Toplitz and XOR.
> 
> Let me if you can add it to your patchset or would like me to send a patch on
> top of yours to add it.

I would prefer you to add the proposed changes on top my patchset. I'm working on the review comments currently and I will post the patchset once the patches are ready.

> 
> Thanks,
> Amir
