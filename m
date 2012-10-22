From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast address
 to ALE table
Date: Mon, 22 Oct 2012 10:46:14 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD6D3@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-4-git-send-email-mugunthanvnm@ti.com>
 <20121021112603.GB6756@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:56391 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab2JVKqT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 06:46:19 -0400
In-Reply-To: <20121021112603.GB6756@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Sunday, October 21, 2012 4:56 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast
> address to ALE table
> 
> On Wed, Oct 17, 2012 at 04:15:15AM +0530, Mugunthan V N wrote:
> > @@ -271,6 +273,30 @@ struct cpsw_priv {
> >  			(func)((priv)->slaves + idx, ##arg);	\
> >  	} while (0)
> >
> > +static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
> > +{
> > +	struct cpsw_priv *priv = netdev_priv(ndev);
> > +
> > +	if (ndev->flags & IFF_PROMISC) {
> > +		/* Enable promiscuous mode */
> > +		dev_err(priv->dev, "Ignoring Promiscuous mode\n");
> > +		return;
> 
> Why can't we support promiscuous mode here?
> 

To support promiscuous mode, ALE has to be disabled and but this will
lead to disabling Switch functionality in hardware. So this is not
implemented as of now, It is under development.

Regards
Mugunthan V N
