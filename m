From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 22:54:09 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901232252510.25716@fbirervta.pbzchgretzou.qr>
References: <1232223441.3966.22.camel@localhost.localdomain>  <1232228261.27094.0.camel@macbook.infradead.org>  <20090117221932.GA4956@uranus.ravnborg.org>  <49725B1E.604@kernel.org>  <1232498319.3123.34.camel@localhost.localdomain>
 <1232726359.3504.18.camel@localhost.localdomain> <1232726658.3504.22.camel@localhost.localdomain> <alpine.LSU.2.00.0901231710350.15413@fbirervta.pbzchgretzou.qr> <497A3793.5090502@zytor.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tiwai-l3A5Bk7waGM@public.gmane.org,
	mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <497A3793.5090502-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Friday 2009-01-23 22:33, H. Peter Anvin wrote:
>>
>> I had an objection as previously stated -- namely that
>> <stdint.h> should be included to remain friendly to C++0x
>> programs which should use <cstdint> instead. Forcing
>> stdint.h is therefore not nice.
>
> FWIW, it's kind of pointless in that case; <cstdint> exports it into the std::
> namespace rather than the root namespace, so using stdint types still don't
> work.

Hm, maybe g++ defaults to std? Because this works without me using
"using std;"

#include <cstdint>
int main(void)
{
	uint32_t x;
}
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
