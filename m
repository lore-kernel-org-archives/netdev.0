From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH FEAT] ibmvnic: Feature implementation of Vital Product
 Data (VPD) for the ibmvnic driver
Date: Wed, 1 Nov 2017 18:17:08 +0100
Message-ID: <20171101171708.GA24320@lunn.ch>
References: <20171101143959.14992-1-desnesn@linux.vnet.ibm.com>
 <b216c469-f090-e3b5-aaa4-16295db01eb4@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Desnes Augusto Nunes do Rosario <desnesn@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:36774 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751682AbdKARRL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 13:17:11 -0400
Content-Disposition: inline
In-Reply-To: <b216c469-f090-e3b5-aaa4-16295db01eb4@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
> > index d0cff28..120f3c0 100644
> > --- a/drivers/net/ethernet/ibm/ibmvnic.c
> > +++ b/drivers/net/ethernet/ibm/ibmvnic.c
> > @@ -107,6 +107,9 @@ static union sub_crq *ibmvnic_next_scrq(struct ibmvnic_adapter *,
> >  					struct ibmvnic_sub_crq_queue *);
> >  static int ibmvnic_poll(struct napi_struct *napi, int data);
> >  static void send_map_query(struct ibmvnic_adapter *adapter);
> > +static int ibmvnic_get_vpd(struct ibmvnic_adapter *);
> > +static void handle_vpd_size_rsp(union ibmvnic_crq *, struct ibmvnic_adapter *);
> > +static void handle_vpd_rsp(union ibmvnic_crq *,struct ibmvnic_adapter *);
> 
> There should be a space after the comma.

And you should try to avoid forward declarations. Move the code around
so they are not needed.

   Andrew
