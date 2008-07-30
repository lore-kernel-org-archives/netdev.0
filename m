From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/2] net: support for TX timestamps
Date: Wed, 30 Jul 2008 16:36:55 +0300
Message-ID: <200807301636.55670.opurdila@ixiacom.com>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com> <200807301615.52953.opurdila@ixiacom.com> <1217424856.30512.180.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:21128 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753308AbYG3Nj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 09:39:26 -0400
In-Reply-To: <1217424856.30512.180.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 July 2008, Patrick Ohly wrote:

> > I don't think that skb->sk is guaranteed to be around in hard_start_xmit.
> > But we should not need it, if we overload the skb->tstamp, right?
>
> skb->sk is needed in skb_tx_timestamp() to send the copied skb with the
> time stamp back to the application, isn't it? skb_tx_timestamp() won't
> crash, but it won't be able to do the desired action either. Overloading
> skb->tstamp doesn't help with that.
>

Yes you are right :)

> I don't know where the connection to the originating socket is lost, but
> in linux-2.6 as of one week ago (not 2.6.26, as I said above) the
> skb->sk pointer is indeed NULL for the PTP broadcast packets - I just
> checked again.

Thanks for letting me know, I will look into it.

tavi

