From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/usb: kalmia: Various fixes for better support of
 non-x86 architectures.
Date: Fri, 24 Jun 2011 15:55:13 +0400
Message-ID: <4E047B21.5080104@ru.mvista.com>
References: <Pine.LNX.4.44L0.1106231025340.2033-100000@iolanthe.rowland.org> <4E0353D0.1060604@ru.mvista.com> <201106240742.38806.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201106240742.38806.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 24-06-2011 9:42, Oliver Neukum wrote:

>>>>      Actually 'const' alone should've been enough for the variable to be placed
>>>> in the data section ISO stack.

>>> I don't understand what "ISO stack" means here.

>>      ISO == instead of.

> That doesn't matter. If you are sufficiently unlucky it will land on
> a page boundary. You must not do DMA on the data section either.

    Who said it was going to do DMA on the data section? The arrays got copied 
to heap-allocated buffer before DMA. But allocating those arrays on stack was 
not optimal anyway.

> 	Regards
> 		Oliver
>

WBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
