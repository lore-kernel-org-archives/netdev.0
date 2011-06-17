From: Bernard Metzler <BMT@zurich.ibm.com>
Subject: Re: software iwarp stack update
Date: Fri, 17 Jun 2011 16:23:12 +0200
Message-ID: <OF2FB0811C.9340951D-ONC12578B2.004E9610-C12578B2.004F07C3@ch.ibm.com>
References: <BANLkTikE-oc2qWZec+2BfWuUy-oNdf-opg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:44201 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab1FQOXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 10:23:37 -0400
In-Reply-To: <BANLkTikE-oc2qWZec+2BfWuUy-oNdf-opg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, let me put in all the -ENOSYS functions.
I did not know about that distinction between user
and kernel level clients.

Thanks,
Bernard.

linux-rdma-owner@vger.kernel.org wrote on 06/16/2011 08:06:44 PM:

> On Thu, Jun 16, 2011 at 7:20 PM, Roland Dreier <roland@purestorage.com>
wrote:
> > It does seem we are missing an IB_MANDATORY_FUNC
> > entry for modify_port in ib_device_check_mandatory; or on
> > the flip side we are missing a check of modify_port and a
> > -ENOSYS return... I guess modify_port does not really make
> > sense for iWARP so probably the second option is better.
>
> It's not just ib_modify_port() - there are several other functions in
> the amso and cxgb* drivers that do nothing more than returning either
> -ENOSYS or ERR_PTR(-ENOSYS).
>
> Bart.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

