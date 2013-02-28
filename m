From: Yan Burman <yanb@mellanox.com>
Subject: RE: [RFC PATCH 3/3] mlx4: Use default fdb handlers when not
 multifunction.
Date: Thu, 28 Feb 2013 12:32:23 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB87346219AC704@MTLDAG02.mtl.com>
References: <1361987164-15280-1-git-send-email-vyasevic@redhat.com>
	<1361987164-15280-4-git-send-email-vyasevic@redhat.com>
	<512EDCC7.8050207@intel.com>
 <CAJZOPZLcphuZEXR+jhT35=qtOq9bfxWzWEokN6UrMorciCvvsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:37700 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751937Ab3B1Mil convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 07:38:41 -0500
In-Reply-To: <CAJZOPZLcphuZEXR+jhT35=qtOq9bfxWzWEokN6UrMorciCvvsA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Thu, Feb 28, 2013 at 6:27 AM
> Subject: Re: [RFC PATCH 3/3] mlx4: Use default fdb handlers when not
> multifunction.
> To: Vlad Yasevich <vyasevic@redhat.com>, Amir Vadai <amirv@mellanox.com>
> Cc: netdev@vger.kernel.org, davem@davemloft.net
> 
> 
> On 2/27/2013 9:46 AM, Vlad Yasevich wrote:
> >
> > Allow the use of ndo_dflt_fdb_<add|del|dump> when the adapter is not
> > configured with virtual functins (!mlx4_is_mfunc()) This allows proper
> > IFF_UNICAST_FLT support and allows for additional handling by the
> > driver if needed.
> >
> > CC: Amir Vadai <amirv@mellanox.com>
> > Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> > ---
> >   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 +++---------
> >   1 files changed, 3 insertions(+), 9 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > index 5385474..5732025 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > @@ -1934,7 +1934,7 @@ static int mlx4_en_fdb_add(struct ndmsg *ndm,
> > struct nlattr *tb[],
> 
> 
> Amir are the default ops good enough here?
> 

The default ops can be used instead of mlx4 fdb_add, fdb_delete, and fdb_dump.

Yan
