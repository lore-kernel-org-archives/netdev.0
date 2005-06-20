From: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch 02/15] ppp_mppe: add PPP MPPE encryption module
Date: Mon, 20 Jun 2005 18:45:18 -0400
Message-ID: <42B746FE.60504@pobox.com>
References: <200506202231.j5KMVpfS024640@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt_Domsch-8PEkshWhKlo@public.gmane.org, Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org,
	james.cameron-VXdhtT5mjnY@public.gmane.org, pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: akpm-3NddpPZAyC0@public.gmane.org
In-Reply-To: <200506202231.j5KMVpfS024640-bipKiLWnuIsyyg0EjBt7GtHuzzzSOjJt@public.gmane.org>
Sender: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=pptpclient-devel>
List-Id: netdev.vger.kernel.org

akpm-3NddpPZAyC0@public.gmane.org wrote:
> From: Matt Domsch <Matt_Domsch-8PEkshWhKlo@public.gmane.org>
> 
> The patch below implements the Microsoft Point-to-Point Encryption method
> as a PPP compressor/decompressor.  This is necessary for Linux clients and
> servers to interoperate with Microsoft Point-to-Point Tunneling Protocol
> (PPTP) servers (either Microsoft PPTP servers or the poptop project) which
> use MPPE to encrypt data when creating a VPN.
> 
> This patch differs from the kernel_ppp_mppe DKMS pacakge at
> pptpclient.sourceforge.net by utilizing the kernel crypto routines rather
> than providing its own SHA1 and arcfour implementations.
> 
> Minor changes to ppp_generic.c try to prevent a link from disabling
> compression (in our case, the encryption) after it has started using
> compression (encryption).
> 
> Feedback to <pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> please.
> 
> Signed-off-by: Matt Domsch <Matt_Domsch-8PEkshWhKlo@public.gmane.org>
> Cc: James Cameron <james.cameron-VXdhtT5mjnY@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Signed-off-by: Brice Goglin <Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>

I'll review this, but ppp stuff really needs to go Paul MacKerras...


	Jeff





-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
