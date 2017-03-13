From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 04/10] net: Add netif_is_vrf_master helper
Date: Mon, 13 Mar 2017 17:01:03 +0200
Message-ID: <20170313150103.GA32446@splinter.mtl.com>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-4-git-send-email-jiri@resnulli.us>
 <d3d82369-bea2-ea7e-0912-66061bd6cc91@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47542 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753359AbdCMPBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:01:21 -0400
Content-Disposition: inline
In-Reply-To: <d3d82369-bea2-ea7e-0912-66061bd6cc91@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 08:39:19AM -0600, David Ahern wrote:
> On 3/13/17 1:38 AM, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > Drivers capable of offloading VRF configurations need to know the ports
> > are enslaved to an actual VRF device and not some other L3 master.
> > 
> > Add a flag to indicate netdev is a VRF master and a corresponding
> > helper.
> > 
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> >  drivers/net/vrf.c         | 2 +-
> >  include/linux/netdevice.h | 8 ++++++++
> >  2 files changed, 9 insertions(+), 1 deletion(-)
> > 
> 
> IFF_VRF_MASTER was renamed IFF_L3MDEV_MASTER 18 months ago.

But IFF_L3MDEV_MASTER isn't specific to the VRF driver. It can be set by
other drivers including future ones that might be introduced. I need to
allow enslavement to a VRF master, but reject others.
