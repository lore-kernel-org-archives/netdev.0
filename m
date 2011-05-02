From: Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Subject: Re: Frequent spurious tx_timeouts for libertas
Date: Mon, 2 May 2011 21:01:04 +0100
Message-ID: <BANLkTikHRAYYPj3y9JWLjpatdOCiRXD5Nw@mail.gmail.com>
References: <BANLkTintnaEj0DDjwQJjc4wpuz-c_QOGyg@mail.gmail.com>
	<1304303082.2833.159.camel@localhost>
	<BANLkTi=FT4v=Jvv5bQpUX15R87kPudKq=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=FT4v=Jvv5bQpUX15R87kPudKq=Q@mail.gmail.com>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2 May 2011 20:59, Daniel Drake <dsd-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org> wrote:
> dev->trans_start is unconditionally initialized by dev_activate() in
> sch_generic.c:

Also, many drivers (including libertas) set it in their tx_timeout handlers:
   dev->trans_start = jiffies; /* prevent tx timeout */
I don't understand why (the TX timeout has already occurred, it can't
be prevented at that stage).

Daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
