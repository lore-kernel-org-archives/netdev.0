From: Jarkko Sakkinen <jarkko.sakkinen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 00/12] xen: add common function for
	reading optional value
Date: Mon, 7 Nov 2016 08:20:08 -0800
Message-ID: <20161107162008.a2x2lgn3syvv7m23@intel.com>
References: <1477932510-28594-1-git-send-email-jgross@suse.com>
	<8d314b86-4a28-5628-2a79-842a2fafc4c1@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Juergen Gross <jgross-IBi9RG/b67k@public.gmane.org>, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wei.liu2-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tomi.valkeinen-l0cyMroinI0@public.gmane.org, dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawuEi8DpZVb4nw@public.gmane.org,
	tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	paul.durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org, roger.pau-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org
To: David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <tpmdd-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8d314b86-4a28-5628-2a79-842a2fafc4c1-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tpmdd-devel>,
	<mailto:tpmdd-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tpmdd-devel>
List-Post: <mailto:tpmdd-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:tpmdd-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tpmdd-devel>,
	<mailto:tpmdd-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: tpmdd-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2016 at 11:08:09AM +0000, David Vrabel wrote:
> On 31/10/16 16:48, Juergen Gross wrote:
> > There are multiple instances of code reading an optional unsigned
> > parameter from Xenstore via xenbus_scanf(). Instead of repeating the
> > same code over and over add a service function doing the job and
> > replace the call of xenbus_scanf() with the call of the new function
> > where appropriate.
> 
> Acked-by: David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> 
> Please queue for the next release.

If you want this change to tpmdd, please resend it to tpmdd mailing
list and CC it to linux-security-module. Thanks.

> David

/Jarkko

------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
