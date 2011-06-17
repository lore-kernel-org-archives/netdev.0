From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 05/14] SIWv2: User interface: siw_verbs.h, siw_verbs.c, siw_user.h, siw_ae.c
Date: Thu, 16 Jun 2011 17:14:46 -0700
Message-ID: <m2y611fh55.fsf__42166.8607079939$1308271262$gmane$org@firstfloor.org>
References: <1308228127-22634-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: public-netdev-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org,
	public-linux-rdma-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
To: Bernard Metzler
	<public-bmt-OA+xvbQnYDHMbYB6QlFGEg@plane.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:49866 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754875Ab1FQAkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 20:40:51 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1QXMjP-0003WQ-Od
	for netdev@vger.kernel.org; Fri, 17 Jun 2011 02:16:15 +0200
In-Reply-To: <1308228127-22634-1-git-send-email-bmt@zurich.ibm.com> (Bernard
	Metzler's message of "Thu, 16 Jun 2011 14:42:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> writes:
> +
> +/*
> + * siw_async_ev()
> + *
> + * Report Asynchonous event to user.
> + */
> +void siw_async_ev(struct siw_qp *qp, struct siw_cq *cq,
> +		  enum ib_event_type etype)
> +{
> +	static struct ib_event	event;

Static? That looks scary, especially without a lock.


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

