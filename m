From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Patchset - Support for configurable RSS hash key
Date: Sun, 2 Feb 2014 18:10:18 +0200
Message-ID: <20140202161016.GA17000@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:61492 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbaBBQKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 11:10:22 -0500
Received: by mail-wg0-f54.google.com with SMTP id x13so10758714wgg.33
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 08:10:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/14 13:02 +0000, Venkata Duvvuru wrote:
> NIC drivers that support RSS use either a hard-coded value or a random value for the RSS hash key. Irrespective of the type of the key used, the user would want to change the hash key if he/she is not satisfied with the effectiveness of the default hash-key in spreading the incoming flows evenly across the RSS queues.
> 
> This patch set provides support for configuring the RSS hash-key via the ethtool interface.
> 
> The patch set consists of:
> a) ethtool user-land patches
> b) ethtool kernel patch
> c) be2net patch that implements the ethtool hooks

Hi,

I would be happy to add support in setting the hash function in
addition to the hash key.

Mellanox NIC's have support in 2 hash functions: Toplitz and XOR.

Let me if you can add it to your patchset or would like me to send a
patch on top of yours to add it.

Thanks,
Amir
