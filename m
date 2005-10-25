From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation offload support
Date: Wed, 26 Oct 2005 01:22:48 +0200
Message-ID: <20051025232248.GB17794@electric-eye.fr.zoreil.com>
References: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D790@hqemmail02.nvidia.com> <20051025215932.GA17794@electric-eye.fr.zoreil.com> <1130272203.6236.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jeff Garzik <jgarzik@pobox.com>,
        Manfred Spraul <manfred@colorfullife.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1130272203.6236.2.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan <mchan@broadcom.com> :
> On Tue, 2005-10-25 at 23:59 +0200, Francois Romieu wrote:
> 
> > 
> > drivers/net/bnx2.c::bnx2_start_xmit seems bogus.
> > 
> Please explain what did you mean by bogus?

When the CPU sets the entries of a multi-descriptor packet, the first
descriptor is marked read while the next ones are still unset.

If any of BNX2_L2CTX_TX_HOST_{BIDX/BSEQ} prevents the asic to read
beyond 'prod' (or b(yte)seq ?), the ordering does not matter. Right ?

--
Ueimor
