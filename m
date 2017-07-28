From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC] switchdev: generate phys_port_name in the core
Date: Fri, 28 Jul 2017 16:13:40 +0200
Message-ID: <20170728141340.GA2132@lunn.ch>
References: <CAJ3xEMhUs0DfMioSU=gqR_hEs=ZFjUM1bA3nA9LwtTgH93ygDQ@mail.gmail.com>
 <20170728023122.1674-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        David Miller <davem@davemloft.net>, simon.horman@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43780 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751786AbdG1ONo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 10:13:44 -0400
Content-Disposition: inline
In-Reply-To: <20170728023122.1674-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 07:31:22PM -0700, Jakub Kicinski wrote:
> On Thu, 27 Jul 2017 13:30:44 +0300, Or Gerlitz wrote:
> > > want to add port splitting support, for example, reporting the name on
> > > physical ports will become more of a necessity.  
> > 
> > > If we adopt Jiri's suggestion of returning structured data it will be
> > > very easy to give user space type and indexes separately, but we should
> > > probably still return the string for backwards compatibility.  
> > 
> > I am not still clear how the structured data would look like
> 
> I decided to just quickly write the code, that should be easier to 
> understand.  We can probably leave out the netlink part of the API
> if there is no need for it right now, but that's what I ment by
> returning the information in a more structured way.
> 
> Tested-by: nobody :)
> Suggested-by: Jiri (if I understood correctly)
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_rep.c |  8 ++-
>  drivers/net/ethernet/mellanox/mlxsw/switchx2.c   | 10 ++--
>  drivers/net/ethernet/netronome/nfp/nfp_port.c    | 26 ++++-----
>  drivers/net/ethernet/netronome/nfp/nfp_port.h    |  4 +-
>  include/linux/netdevice.h                        | 18 ++++++-
>  include/uapi/linux/if_link.h                     | 16 ++++++
>  net/core/dev.c                                   | 31 +++++++++--
>  net/core/rtnetlink.c                             | 69 ++++++++++++++++++++++++

Hi Jakub

Don't forget net/dsa/slave.c when you go from RFC to a real patch for
submission.

	Andrew
