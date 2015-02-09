From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 15/15] i40e/i40evf: Add call to u64_stats_init to init
Date: Mon, 9 Feb 2015 16:45:43 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264FD30687@ORSMSX102.amr.corp.intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1423478641-3138-16-git-send-email-jeffrey.t.kirsher@intel.com>
 <54D8A36B.8040401@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17904 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761249AbbBIQpv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 11:45:51 -0500
In-Reply-To: <54D8A36B.8040401@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Monday, February 09, 2015 4:09 AM
> To: Kirsher, Jeffrey T; davem@davemloft.net
> Cc: Wyborny, Carolyn; netdev@vger.kernel.org; nhorman@redhat.com;
> sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 15/15] i40e/i40evf: Add call to u64_stats_init to init
> 
> Hello.
> 
[..]
> > +		u64_stats_init(rx_ring->syncp);
> 
>     This is over-indented.
> 
> > +
> >   	/* Round up to nearest 4K */
> >   	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
> >   		? rx_ring->count * sizeof(union i40e_16byte_rx_desc) diff --git
> > a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> > b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> > index 4bf15da..459499a 100644
> > --- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> > +++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
> > @@ -596,6 +596,8 @@ int i40evf_setup_rx_descriptors(struct i40e_ring
> *rx_ring)
> >   	if (!rx_ring->rx_bi)
> >   		goto err;
> >
> > +		u64_stats_init(rx_ring->syncp);
> 
>     Likewise.
> 
> > +
> >   	/* Round up to nearest 4K */
> >   	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
> >   		? rx_ring->count * sizeof(union i40e_16byte_rx_desc)
> 
> WBR, Sergei
Thanks, I have already submitted a patch to correct this, but need to track down the same change in the vf code.  

Jeff, do you know how close it is to submission?  

Carolyn

Carolyn Wyborny 
Linux Development 
Networking Division 
Intel Corporation 
