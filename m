From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Resend: [NETDRV] Merge register_netdev calls
Date: Mon, 20 Sep 2004 15:03:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F2997.9030901@pobox.com>
References: <20040701111914.GA11120@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040701111914.GA11120@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Jun 11, 2004 at 12:08:55PM +1000, herbert wrote:
> 
>>In fact it's really making these ISA/MCA probe() functions more
>>like the ones we have for PCI.
> 
> 
> To illustrate this, let's take the first driver touched by 4/x.
> In 3c503, the function init_module() essentially does
> 
> for each ioaddr
> 	if (do_el2_probe(ioaddr) == 0)
> 		return 0
> 
> And do_el2_probe() just calls el2_probe1() which is similar
> to your average PCI probe function except that the first thing
> it does is to make sure that the device exists at ioaddr.
> 
> This is not that different from PCI where it would look
> like
> 
> for each PCI device matching the vendor/product numbers
> 	if (do_el2_probe(device) == 0)
> 		return 0
> 
> Now before my patch, register_netdev was being called just
> after do_el2_probe() returns.  My patch simply moves it to
> the end of el2_probe1() which is exactly what would happen
> if this were a PCI driver.
> 
> I've rediffed it against your net-drivers-2.6 tree.

so,

there was a lot of churn and I held off on this patch.

could you be convinced to rediff and resend (again)?

	Jeff
