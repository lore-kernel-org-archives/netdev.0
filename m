From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH for-net V2 00/12] net/mlx5_core: Enhance flow steering support
Date: Sun, 10 Jan 2016 10:46:16 +0200
Message-ID: <CAJ3xEMhuv3TBDwtokmL5TUf0LU07EOfJw-P5Q4aKx2t3E6oEhQ@mail.gmail.com>
References: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>, maorg@mellanox.com,
	Matan Barak <matanb@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35468 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcAJIqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 03:46:17 -0500
Received: by mail-io0-f194.google.com with SMTP id 77so8916846ioc.2
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 00:46:16 -0800 (PST)
In-Reply-To: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2016 at 10:39 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Hi Dave,
>
> v0 --> v1 changes:
>   - fixed improperly formatted comments.
>   - compare value of ib_spec->eth.mask.ether_type in network byte order
>      in ('IB/mlx5: Add flow steering utilities').
>
> v1 --> v2 changes:
>   - made sure that service functions added in the IB driver are only static-fied
>     on the last commit, to make sure bisection with -Werror works fine.
>
> v2 has been generated against net-next commit c9c9931 "Merge tag
> 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge"
>
> The series is signed by Matan who was revently assigned to a maintainer for
> the mlx5_core and IB drivers (this is a 4.5-rc1 change to the maintainers file coming
> from the rdma tree) -- as such I didn't see a neeed to add my signature (Or).

> This series adds three new functionalists to the driver flow-steering
> infrastructure: auto-grouped flow tables, chaining of flow tables and
> updates for the root flow table.
[...]
> Regards,
> Moni, Matan and Maor

>
> Maor Gottlieb (12):
>   net/mlx5_core: Introduce flow steering autogrouped flow table
>   net/mlx5_core: Add utilities to find next and prev flow-tables
>   net/mlx5_core: Managing root flow table
>   net/mlx5_core: Introduce modify flow table command
>   net/mlx5_core: Connect flow tables
>   net/mlx5_core: Set priority attributes
>   net/mlx5_core: Initialize namespaces only when supported by device
>   net/mlx5_core: Enable flow steering support for the IB driver
>   net/mlx5_core: Make ipv4/ipv6 location more clear
>   net/mlx5_core: Export flow steering API
>   IB/mlx5: Add flow steering utilities
>   IB/mlx5: Add flow steering support
>
>  drivers/infiniband/hw/mlx5/main.c                 | 460 ++++++++++++++++
>  drivers/infiniband/hw/mlx5/mlx5_ib.h              |  45 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  52 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  |   9 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 605 +++++++++++++++++++---
>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  14 +
>  include/linux/mlx5/device.h                       |   2 +
>  include/linux/mlx5/fs.h                           |   8 +
>  include/linux/mlx5/mlx5_ifc.h                     | 105 +++-
>  9 files changed, 1222 insertions(+), 78 deletions(-)
>
> --
> 1.8.3.1


Dave, I made small mistake here --- the auto-generated part above is
wrong and belongs to V0. Below is the correct auto-generated one.

I prefer not to spam you with re-spin of V2 just for that, hope this is fine.

Or.

> *** BLURB HERE ***
>
> Maor Gottlieb (12):
>   net/mlx5_core: Introduce flow steering autogrouped flow table
>   net/mlx5_core: Add utilities to find next and prev flow-tables
>   net/mlx5_core: Managing root flow table
>   net/mlx5_core: Introduce modify flow table command
>   net/mlx5_core: Connect flow tables
>   net/mlx5_core: Set priority attributes
>   net/mlx5_core: Initialize namespaces only when supported by device
>   net/mlx5_core: Enable flow steering support for the IB driver
>   net/mlx5_core: Make ipv4/ipv6 location more clear
>   net/mlx5_core: Export flow steering API
>   IB/mlx5: Add flow steering utilities
>   IB/mlx5: Add flow steering support
>
>  drivers/infiniband/hw/mlx5/main.c                 | 463 +++++++++++++++++
>  drivers/infiniband/hw/mlx5/mlx5_ib.h              |  45 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  52 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  |   9 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 601 +++++++++++++++++++---
>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  14 +
>  include/linux/mlx5/device.h                       |   2 +
>  include/linux/mlx5/fs.h                           |  18 +
>  include/linux/mlx5/mlx5_ifc.h                     | 105 +++-
>  9 files changed, 1233 insertions(+), 76 deletions(-)
>
> --
> 2.3.7
