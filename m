From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation offload support
Date: Tue, 25 Oct 2005 23:59:33 +0200
Message-ID: <20051025215932.GA17794@electric-eye.fr.zoreil.com>
References: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D790@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        Manfred Spraul <manfred@colorfullife.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Content-Disposition: inline
In-Reply-To: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D790@hqemmail02.nvidia.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ayaz Abdulla <AAbdulla@nvidia.com> :
> We give the fragments in that order to ensure they are all setup before
> hardware starts looking at them.

If you are curious of different ways to do it, you can look at:
- drivers/net/r8169.c::rtl8169_start_xmit
- drivers/net/skge.c::skge_xmit_frame

drivers/net/bnx2.c::bnx2_start_xmit seems bogus.

--
Ueimor
