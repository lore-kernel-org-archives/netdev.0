From: David Miller <davem@davemloft.net>
Subject: Re: [BUG 2.6.34-rc1] bogus "(null)" in tulip init messages
Date: Wed, 10 Mar 2010 08:41:04 -0800 (PST)
Message-ID: <20100310.084104.201710892.davem@davemloft.net>
References: <19351.48072.777754.465084@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@mcmartin.ca, linux-kernel@vger.kernel.org, joe@perches.com
To: mikpe@it.uu.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <19351.48072.777754.465084@pilspetsen.it.uu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikael Pettersson <mikpe@it.uu.se>
Date: Wed, 10 Mar 2010 16:33:28 +0100

> Booting 2.6.34-rc1 on a machine with a tulip nic I see
> a number of kernel messages that include "(null)" where
> previous kernels included the string "tulip0":

CC:'ing the guilty party :-)  It's one of the following
commits:

commit 44298ec0f20c45b9be96e181976aef1152d373b2
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:29 2010 +0000

    tulip/xircom_cb.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
    Remove DRV_NAME and xircom_cb from pr_<level>
    Convert embedded function names in logging messages to %s, __func__
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit a1e37bc5e2d0ff8d025221e27c2bfff762072311
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:28 2010 +0000

    tulip/winbond-840.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    Convert %d.%d.%d.%d to %pI4
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit e02fb7aa0714ca9357571bb15ef0fe278a150cc7
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:27 2010 +0000

    tulip/uli526x.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
    Remove DRV_NAME from logging messages
    Add do {} while(0) to ULI526X_DBUG macro
    Make SHOW_MEDIA_TYPE macro more readable
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 27146c43c4dbb727c4a211541af46577de2984af
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:26 2010 +0000

    tulip/timer.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 22086a1172b69b9f6200e169dc99a252a204affb
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:25 2010 +0000

    tulip/pnic2.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 1df8bbd1420705277cd382b1386cda724d61a678
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:24 2010 +0000

    tulip/pnic.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit fa0b9a4c41490d550ebd3bd418f4551c989fec5d
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:23 2010 +0000

    tulip/media.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit abe02af8263ae17e201994a1be7fc5eac6642acf
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:22 2010 +0000

    tulip/interrupt.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit e9cd1cbcda5e21706b03b543b1b73600b07f323f
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:21 2010 +0000

    tulip/eeprom.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit dde7c8ef167996689bc464eb65d2b09ef05263c2
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:20 2010 +0000

    tulip/dmfe.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
    Remove 'DRV_NAME ": ' from logging messages
    Convert commented out printks to pr_debug
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit f639dc7dadcbd97f1d666d5ffe00eab1ea3c0f6d
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:19 2010 +0000

    tulip/de2104x.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 985a63ed3faf0faaba840d806f5ca4d360d13ad3
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:18 2010 +0000

    tulip/21142.c: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where a dev is available
    Convert printks to pr_<level> where not
    Coalesce format strings
    Change print formats with %d.dx to %0dx
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit d60bec4eb7076acfc940cca3f9f219e7653a1466
Author: Joe Perches <joe@perches.com>
Date:   Thu Jan 28 20:59:17 2010 +0000

    tulip_core: Use dev_<level> and pr_<level>
    
    Convert printks to dev_<level> where appropriate
    Convert printks to pr_<level>
    Change print formats with %d.dx to %0dx
    Coalesce long formats
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


> --- dmesg-2.6.33	2010-02-26 12:58:32.000000000 +0100
> +++ dmesg-2.6.34-rc1	2010-03-10 16:17:06.000000000 +0100
> ...
>  Linux Tulip driver version 1.1.15 (Feb 27, 2007)
>  tulip 0000:00:0f.0: enabling device (0014 -> 0017)
> -tulip0:  EEPROM default media type Autosense.
> -tulip0:  Index #0 - Media 10baseT (#0) described by a 21142 Serial PHY (2) block.
> -tulip0:  Index #1 - Media 10baseT-FDX (#4) described by a 21142 Serial PHY (2) block.
> -tulip0:  Index #2 - Media 100baseTx (#3) described by a 21143 SYM PHY (4) block.
> -tulip0:  Index #3 - Media 100baseTx-FDX (#5) described by a 21143 SYM PHY (4) block.
> -tulip0:  Index #4 - Media 100baseTx (#3) described by a 21143 reset method (5) block.
> -eth0: Digital DS21142/43 Tulip rev 48 at Port 0x800, 00:00:c5:50:f9:51, IRQ 25.
> + (null): EEPROM default media type Autosense
> + (null): Index #0 - Media 10baseT (#0) described by a 21142 Serial PHY (2) block
> + (null): Index #1 - Media 10baseT-FDX (#4) described by a 21142 Serial PHY (2) block
> + (null): Index #2 - Media 100baseTx (#3) described by a 21143 SYM PHY (4) block
> + (null): Index #3 - Media 100baseTx-FDX (#5) described by a 21143 SYM PHY (4) block
> + (null): Index #4 - Media 100baseTx (#3) described by a 21143 reset method (5) block
> +net eth0: Digital DS21142/43 Tulip rev 48 at Port 0x800, 00:00:c5:50:f9:51, IRQ 25
> 
> Apart from this the tulip driver seems to work in 2.6.34-rc1.
> 
> /Mikael
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
