From: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Subject: Re: [PATCH 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Thu, 15 Dec 2016 18:18:23 -0700
Message-ID: <20161216011823.GC25227@animalcreek.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
 <1481841044-4314-3-git-send-email-glansberry@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
        aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org, Jaret Cantu <jaret.cantu-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481841044-4314-3-git-send-email-glansberry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 05:30:44PM -0500, Geoff Lansberry wrote:
> From: Jaret Cantu <jaret.cantu-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
> 
> Repeated polling attempts cause a NULL dereference error to occur.
> This is because the curent state of the trf7970a is reading but
> a request has been made to send a command.
> 
> The solution is to properly kill the waiting reading (workqueue)
> before failing on the send.

Maybe its just me but I find this description a little hard to grok.
Mind reworking it?

The patch itself looks fine.

Thanks,

Mark
--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
