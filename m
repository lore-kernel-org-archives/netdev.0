From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next] net/ncsi: Define {add, kill}_vid callbacks for
 !CONFIG_NET_NCSI
Date: Fri, 01 Sep 2017 07:14:10 +1000
Message-ID: <1504214050.4974.52.camel@kernel.crashing.org>
References: <20170831033846.23538-1-sam@mendozajonas.com>
         <20170831152414.GB69617@mauery>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: Vernon Mauery <vernon.mauery@linux.intel.com>,
        Samuel Mendoza-Jonas <sam@mendozajonas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41394 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751355AbdHaVi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 17:38:59 -0400
In-Reply-To: <20170831152414.GB69617@mauery>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 08:24 -0700, Vernon Mauery wrote:
>  +int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
> > +{
> > +     return -ENOTTY;
> > +}
> > +int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
> > +{
> > +     return -ENOTTY;
> > +}
> 
> These should be static functions because they are defined in the header 
> file or you will get multiple symbol definitions.

static inline even or you'll get warning about them being unused iirc.

Cheers,
Ben.
