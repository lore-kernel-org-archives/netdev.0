From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Notify changes in UDP encapsulation via netlink
Date: Tue, 28 Oct 2008 15:34:15 -0700 (PDT)
Message-ID: <20081028.153415.152122885.davem@davemloft.net>
References: <20081028085119.6A30EEF9BA@strongswan.org>
	<20081028.114828.158507859.davem@davemloft.net>
	<1225226660.6976.18.camel@martin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50799
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751521AbYJ1Weh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:34:37 -0400
In-Reply-To: <1225226660.6976.18.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Willi <martin@strongswan.org>
Date: Tue, 28 Oct 2008 21:44:20 +0100

> >  static struct xfrm_mgr netlink_mgr = {
> >         .id             = "netlink",
> >         .notify         = xfrm_send_state_notify,
> >         .notify_policy  = xfrm_send_policy_notify,
> >         .report         = xfrm_send_report,
> >         .migrate        = xfrm_send_migrate,
> > +       .new_mapping    = xfrm_send_mapping,
> > };
> 
> This operation is invoked from net/ipv4/esp4.c through the
> km_new_mapping() function, km_new_mapping() invokes all registered key
> managers. It is already implemented in the PF_KEY interface (pfkeyv2_mgr
> in af_key.c), but is missing in the netlink xfrm interface. The patch
> adds this functionality to the netlink interface.

Sorry, I didn't pick up on that.  Thanks for the explanation.
