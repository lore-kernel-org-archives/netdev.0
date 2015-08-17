From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: avoid vxlan offloading on multichannel
 configs
Date: Mon, 17 Aug 2015 14:30:26 -0700 (PDT)
Message-ID: <20150817.143026.37154503480355591.davem@davemloft.net>
References: <1439584201-8699-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@avagotech.com,
	ajit.khaparde@avagotech.com, padmanabh.ratnakar@avagotech.com,
	sriharsha.basavapatna@avagotech.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbbHQVa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:30:27 -0400
In-Reply-To: <1439584201-8699-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Fri, 14 Aug 2015 22:30:01 +0200

> VxLAN offloading is not functional if the NIC is running in multichannel
> mode (UMC, FLEX-10, VNIC...). Enabling this additionally kills whole
> connectivity through the NIC and the device needs to be down and up to
> restore it. The firmware should take care about it and does not allow
> the conversion of interface to tunnel type (be_cmd_manage_iface) or should
> support VxLAN offloading if multichannel config is enabled.
> I have tested this on the latest available firmware (10.6.144.21).
 ...
> Cc: Sathya Perla <sathya.perla@avagotech.com>
> Cc: Ajit Khaparde <ajit.khaparde@avagotech.com>
> Cc: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
