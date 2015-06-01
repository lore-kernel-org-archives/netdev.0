From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 1 Jun 2015 09:59:17 +0900
Message-ID: <20150601005917.GB5320@kroah.com>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.20.1505311628420.16456-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 31, 2015 at 04:37:11PM +0200, Enrico Mioso wrote:
> Hello guys.
> I am writing to you all to ask for help and assistance in refactoring the
> cdc_ncm driver to support newer devices.
> In particular - I would need step-by-step guidance in doing this: or any
> other kind of help would be anyway greatly apreciated.
> 
> 1 - What we need:
>   We would need to refactor the driver to be able to re-order parts of the NCM
>   package itself.
>   In particular, being a single NCM frame composed of different parts, we would
>   need more flexibility in changing their order.

Do you have hardware that needs this now?  What exactly needs to be done
here that currently doesn't work?

> 2 - What might be nice
>   To do so, it would be nice to have the driver queue up frames, sending them
>   out as needed. this already happens to a certain extent, but the NCM package
>   is created in the process and updated in the while as I understood the code.
>   The best thing would be to have the NCM package created only before sending
>   it out, to achieve for best performance and code readability.

Would this really make things faster?

> I already contactedprivately some of you to have some more insight on what
> needs to be done, and to understand better how to organize the effort. I
> unfortunately miss the time to do this right now: and infact I can't even be
> sure to be able to do this, due to various problems (my tesis, my life in
> general).
> But gathering more informations and in general trying to get some help is
> the best thing I feel like doing right now.
> 
> The compelling reasons I find for trying to fix the situation are:
> 1 - The fact these drivers are used in different products integrating or
>   interfacing with 3G/4G technologies.

Is there hardware that has out-of-tree drivers that implement what you
are referring to here?  Or does someone just want this to make the
hardware work "better"?

I think we need more specifics before being able to determine exactly
what needs to be done.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
