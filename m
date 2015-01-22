From: wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 22 Jan 2015 00:20:59 -0000
Message-ID: <f9cbb34c9228b2af7ed6c1c96a6aa61c.squirrel@www.codeaurora.org>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
    <2318041.V2OJAPu7gC@wuerfel>
    <3ad19b16fe5c58612479f70c052d0045.squirrel@www.codeaurora.org>
    <1702448.pOVnDx4KzI@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Arnd Bergmann" <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1702448.pOVnDx4KzI@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Right. For review purposes, I think it would be helpful to split this
> huge patch into several steps then:
>
> - add a base driver
> - add the overlay interface
> - add the nss driver
>
> Ideally more of them.

The nss-drv driver is open sourced but we are currently not planning to
upstream to linux kernel yet because we are still actively adding new
features
https://www.codeaurora.org/cgit/quic/qsdk/oss/lklm/nss-drv

> Thanks for the description, this sounds very interesting indeed. I do
> have more questions though: how do you get the rules into the NSS driver?
> Does this get handled transparently by the openvswitch driver or
> did you have to add new user interfaces for it?
>
> 	Arnd
>

No, we are not using openvswitch. We have a connection manager monitoring
conntrack events and creates rules then send it through the interface
built in nss-drv.

Thanks,
Stephen

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
