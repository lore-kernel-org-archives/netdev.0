From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 10:56:35 +0100
Message-ID: <20080516105635.6cb1f505@core>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	<20080515142154.0595e475@core>
	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
	<20080515173939.1ec968be@core>
	<482C7DA3.1090809@garzik.org>
	<482C953A.4080205@garzik.org>
	<87abirytxj.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:34944 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752722AbYEPKI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 06:08:56 -0400
In-Reply-To: <87abirytxj.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2008 02:27:36 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> Jeff Garzik <jeff@garzik.org> writes:
> >
> > A hw_random driver for TPM still needs to (a) parse the TPM header for
> > return code, (b) extract RNG bytes out at offset 14, and (c) figure
> > out some way to get a tpm_chip pointer.
> 
> (d) auto feed the information into random.c. Otherwise it'll be useless
> for most people.

No - you don't want to do FIPS randomness verification in kernel space.
Plus all the other random generator inputs are done via the user space
daemon as they should be.
