From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip_vti: fix sparse warnings for VTI_ISVTI
Date: Wed, 11 Jun 2014 08:40:36 -0700
Message-ID: <20140611084036.11f234f0@nehalam.linuxnetplumber.net>
References: <20140611150914.c3cb48bb8a1a760564f5db6e@qrator.net>
	<20140611160215.7b0fbe7c4f42cf02b5496852@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: Dmitry Popov <ixaphire@qrator.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140611160215.7b0fbe7c4f42cf02b5496852@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jun 2014 16:02:15 +0400
Dmitry Popov <ixaphire@qrator.net> wrote:

> On Wed, 11 Jun 2014 15:09:14 +0400
> Dmitry Popov <ixaphire@qrator.net> wrote:
> 
> > 
> > Since VTI_ISVTI is always used with ip_tunnel_parm->i_flags (which is __be16),
> > we can __force cast VTI_ISVTI to __be16 in header file.
> > 
> 
> If this patch is okay I will submit it to iproute2 too. if_tunnel.h has to be
> synced.

don't bother with iproute2 patch. I periodically resync sanitized headers from
kernel to iproute2.
