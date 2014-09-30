From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/4] net/mlx5_core: Use hardware registers
 description header file
Date: Tue, 30 Sep 2014 08:34:49 -0700
Message-ID: <20140930153445.GA9303@localhost.westell.com>
References: <1412082135-30229-1-git-send-email-eli@mellanox.com>
 <1412082135-30229-4-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38823 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaI3Pew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:34:52 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so4828274pdi.38
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 08:34:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1412082135-30229-4-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 04:02:13PM +0300, Eli Cohen wrote:
> Add an auto generated header file that describes hardware registers along with
> set of macros that set/get values. The macros do static checks to avoid
> overflow, handle endianess, and overall provide a clean way to code commands.
> 
> A few commands were removed since they are not supported currently and will be
> added when support is available.
> 
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c |   36 -
>  drivers/net/ethernet/mellanox/mlx5/core/qp.c  |    3 -
>  include/linux/mlx5/device.h                   |   74 +
>  include/linux/mlx5/driver.h                   |   76 +-
>  include/linux/mlx5/mlx5_ifc.h                 | 4464 +++++++++++++++++++++++++
>  5 files changed, 4539 insertions(+), 114 deletions(-)

I find hard time believing that all of 4k auto generated macros
are actually used. Could you trim it down to only usable bits?
