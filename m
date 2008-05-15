From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 10/13] QLogic VNIC: Driver Statistics collection
Date: Thu, 15 May 2008 15:33:56 -0700
Message-ID: <adabq37dwob.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430172055.31725.70663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:28725 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbYEOWeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 18:34:04 -0400
In-Reply-To: <20080430172055.31725.70663.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:50:55 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +#else	/*CONFIG_INIFINIBAND_VNIC_STATS*/
 > +
 > +static inline void vnic_connected_stats(struct vnic *vnic)
 > +{
 > +	;
 > +}

there are an awful lot of stubs here.  Do you really expect anyone to
set CONFIG_INFINIBAND_QLGC_VNIC_STATS=n?

 - R.
