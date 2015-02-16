From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 2/9] be2net: replace (1 << x) with BIT(x)
Date: Mon, 16 Feb 2015 12:55:26 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C74C34365@CMEXMB1.ad.emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
 <1423228723-10919-3-git-send-email-sathya.perla@emulex.com>
 <54E1DDF4.5040901@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:29680 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbbBPM4r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 07:56:47 -0500
In-Reply-To: <54E1DDF4.5040901@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> 
> Hello.
> 
> On 2/6/2015 4:18 PM, Sathya Perla wrote:
> 
> > From: Vasundhara Volam <vasundhara.volam@emulex.com>
> 
> > BIT(x) is the preffered usage.
> 
>     Preferred.
:-) As this is a harmless spelling mistake only in the changelog,
I'll not bother sending a new patch for this!

> 
> [...]
> 
> > diff --git a/drivers/net/ethernet/emulex/benet/be.h
> b/drivers/net/ethernet/emulex/benet/be.h
> > index 3b1d59d..9869556 100644
> > --- a/drivers/net/ethernet/emulex/benet/be.h
> > +++ b/drivers/net/ethernet/emulex/benet/be.h
> > @@ -361,15 +361,15 @@ enum vf_state {
> >   	ASSIGNED = 1
> >   };
> >
> > -#define BE_FLAGS_LINK_STATUS_INIT		1
> > -#define BE_FLAGS_SRIOV_ENABLED			(1 << 2)
> > -#define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
> > -#define BE_FLAGS_VLAN_PROMISC			(1 << 4)
> > -#define BE_FLAGS_MCAST_PROMISC			(1 << 5)
> > -#define BE_FLAGS_NAPI_ENABLED			(1 << 9)
> > -#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
> > -#define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
> > -#define BE_FLAGS_SETUP_DONE			(1 << 13)
> > +#define BE_FLAGS_LINK_STATUS_INIT		BIT(1)
> 
>     Not BIT(0)?

Huh, this was not intentional. I'll remember to use bit-0 the next time
we introduce a new bit!

> 
> > +#define BE_FLAGS_SRIOV_ENABLED			BIT(2)
> > +#define BE_FLAGS_WORKER_SCHEDULED		BIT(3)
> > +#define BE_FLAGS_VLAN_PROMISC			BIT(4)
> > +#define BE_FLAGS_MCAST_PROMISC			BIT(5)
> > +#define BE_FLAGS_NAPI_ENABLED			BIT(6)
> > +#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		BIT(7)
> > +#define BE_FLAGS_VXLAN_OFFLOADS			BIT(8)
> > +#define BE_FLAGS_SETUP_DONE			BIT(9)
> 
>     So, you decided to renumber the bits?

Yes, some holes in the bit map were removed.
