From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Wake on LAN for USB ethernet?
Date: Fri, 18 Jan 2013 20:57:32 +0800
Message-ID: <CACVXFVPKWAtJ_GrqvamxqrnagDjwcZfZBXzCJydmJM6pBeUxug@mail.gmail.com>
References: <20130118001214.GA21137@xanatos>
	<CACVXFVOtpzOFAGRJ74XP1NFD1ah_au9e9gqHFiBLuv1jAwZ6cQ@mail.gmail.com>
	<alpine.DEB.2.02.1301181047290.3637@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.02.1301181047290.3637-dzx9CreErbMJK7zW1S5TsVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2013 at 4:53 PM, Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org> wrote:
> The code in the driver is based on the specs from ADMTek (later, Infineon).
> Since i never suspend my machines this feature has not been tested by me.
>
> However, if the proposed patch is the right thing to do i'd be happy to see
> it applied.

I think it is the right thing, at least many network drivers do that, such as
smsc usbnet drivers and many of PCI ethernet drivers.

So I will prepare one formal version for merge.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
