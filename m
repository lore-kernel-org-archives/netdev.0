From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Thu, 18 Jun 2009 15:03:47 +0100
Message-ID: <1245333827.2799.6.camel@achroite>
References: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	michaelc@cs.wisc.edu, gospo@redhat.com, abjoglek@cisco.com,
	jeykholt@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48849 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759827AbZFRODv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:03:51 -0400
In-Reply-To: <20090618050502.30610.69142.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-17 at 22:05 -0700, Scott Feldman wrote:
> Consolidate shared code between enic and fnic drivers.
> 
> [David/James, we need a little help with this one...this single patch
> spans scsi and netdev, so we're not sure which tree/maintainer needs
> to pick up the patch.  Please advise.  It's for 2.6.31.  The patch is
> against linux-2.6.git.]
> 
> The Cisco enic 10G Ethernet driver and the fnic FCoE HBA driver share
> much of the same hardware-access code because enic and fnic devices are
> really two functions on a converged-I/O PCIe device.  This patch
> consolidates the shared code into one shared module, thus eliminating
> the code duplication.  No functional changes are made by the patch.
> 
> Why weren't these consolidated in the first place?  fnic went in late in
> 2.6.30 on the scsi branch (merge exception for new drivers), and it was
> too late to modify enic which was already included in 2.6.28.
> 
> The changes are as follows:
> 
>   o a new module vnic which is shared between fnic and enic
[...]

Please use a less generic name, like "cisco_vnic".  Solarflare is also
using the term vNIC to refer to its hardware virtualisation features and
I wouldn't be surprised if this term came to be used generically in
future .

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

