From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch] 2.6.1-bk1-netdev4 - latent bug
Date: Thu, 15 Jan 2004 00:33:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115003319.B4646@electric-eye.fr.zoreil.com>
References: <20040114233350.A4646@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dpollock@acm.org, damouse@ntlworld.com, brad@mainstreetsoftworks.com,
        kinetik@orcon.net.nz
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040114233350.A4646@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Wed, Jan 14, 2004 at 11:33:50PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[bug expected in common revisions of r8169 driver ?]
> against plain 2.6.x due to endianness conflict. I will regenerate a serie
> for 2.6.1-bk1 in a few minutes.

Serie available at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1-b

Tarball:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1-b/r8169-blob.tar.bz2

I will welcome feedback related to the behavior of the driver once the
following serie is applied on top of 2.6.1-bk1 (may apply to 2.6.1 as well):
r8169-dma-api-tx.patch
r8169-dma-api-rx-buffers.patch
r8169-dma-api-rx-buffers-ahum.patch
r8169-dma-api-rx-buffers-argl.patch
r8169-rx-fill-typo.patch
r8169-start-xmit-fixes.patch
r8169-dma-api-tx-buffers.patch
r8169-tx-index-overflow.patch

No intermediate tests needed.

--
Ueimor
