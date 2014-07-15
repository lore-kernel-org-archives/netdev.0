From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v6 ethtool 0/2] patchset - Support for configurable RSS
 hash key
Date: Tue, 15 Jul 2014 15:24:18 +0000
Message-ID: <e0356375-ac11-4291-9848-e6807c5a8ce9@CMEXHTCAS1.ad.emulex.com>
References: <1f23ef3b-5ffd-4668-aff6-a719dc63fb28@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
To: "ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:34765 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbaGOPYW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 11:24:22 -0400
In-Reply-To: <1f23ef3b-5ffd-4668-aff6-a719dc63fb28@CMEXHTCAS2.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben, 
Are there any  review comments on this patchset?

/Venkat.

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Venkat Duvvuru
> Sent: Friday, June 06, 2014 9:21 PM
> To: ben@decadent.org.uk
> Cc: netdev@vger.kernel.org; Venkat Duvvuru
> Subject: [PATCH v6 ethtool 0/2] patchset - Support for configurable RSS hash
> key
> 
> NIC drivers that support RSS use either a hard-coded value or a random value
> for the RSS hash key. Irrespective of the type of the key used, the user
> would want to change the hash key if he/she is not satisfied with the
> effectiveness of the default hash-key in spreading the incoming flows evenly
> across the RSS queues.
> 
> This patch set adds support for configuring the RSS hash-key via the ethtool
> interface using .X/-x option.
> 
> v6:
> 1. Addressed Ben's comments.
> 2. Fixed memory leaks in do_grxfhindir, do_srxfhindir, do_srxfh, do_grxfh.
> 3. Handled memory allocation failures in do_grxfhindir, do_srxfhindir,
> do_srxfh, do_grxfh.
> 
> Venkat Duvvuru (2):
>   ethtool: Support for configurable RSS hash key
>   ethtool: Support for configurable RSS hash key
> 
>  ethtool-copy.h |  478
> ++++++++++++++++++++++++++++++++++++++++++--------------
>  ethtool.8.in   |   18 ++-
>  ethtool.c      |  390 ++++++++++++++++++++++++++++++++++++++--------
>  3 files changed, 703 insertions(+), 183 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
