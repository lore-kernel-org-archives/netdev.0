From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 30 Jul 2008 12:21:24 -0700
Message-ID: <adabq0fyy8b.fsf@cisco.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	jgarzik@pobox.com, davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com
To: Karen Xie <kxie@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:55391 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbYG3TV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:21:29 -0400
In-Reply-To: <200807300019.m6U0JkdY012558@localhost.localdomain> (Karen Xie's
	message of "Tue, 29 Jul 2008 17:19:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Cxgb3i iSCSI driver

I think a little more detail in the changelog would be
helpful... something like what you had in the 0/1 email (no reason to
put that nice info in an email that will be discarded rather than in the
patch that will be merged).  Maybe:

  The cxgb3i driver provides iscsi acceleration (PDU digest offload and
  payload direct-placement) to the open-iscsi initiator.  It accesses
  the hardware through the cxgb3 module.

I didn't read in detail yet but one quick comments:

 > --- /dev/null
 > +++ b/drivers/scsi/cxgb3i/Kconfig
 > @@ -0,0 +1,6 @@
 > +config SCSI_CXGB3_ISCSI
 > +	tristate "Chelsio S3xx iSCSI support"
 > +	select CHELSIO_T3
 > +	select SCSI_ISCSI_ATTRS
 > +	---help---
 > +	This driver supports iSCSI offload for the Chelsio S3 series devices.

I don't see any other Kconfig changes that hook this Kconfig file into
the build?  Also are there sufficient dependencies to avoid broken
configs here?

