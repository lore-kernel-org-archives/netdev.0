From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] of: add optional naming of interfaces
Date: Wed, 7 Dec 2016 09:49:46 -0800
Message-ID: <626a2f04-6fc0-f04e-671c-4fd1e90db344@gmail.com>
References: <1481116349-20678-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jonas Johansson <jonas.johansson-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>,
        =?UTF-8?Q?Mattias_Walstr=c3=b6m?= <lazzer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Volodymyr Bendiuga <volodymyr.bendiuga-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        volodymyr.bendiuga-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481116349-20678-1-git-send-email-volodymyr.bendiuga-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/07/2016 05:12 AM, Volodymyr Bendiuga wrote:
> From: Jonas Johansson <jonas.johansson-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>
> 
> Signed-off-by: Mattias Walström <lazzer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Jonas Johansson <jonas.johansson-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>

This does not belong to the Device Tree, there should be plenty of
information in user-space to make an educated device rename. I
definitively understand that some drivers (e.g: dsa) do actually get
their interface name from Device Tree directly (label property), but
this is probably the one and only case where this may be tolerated.

Besides, if you submit such a change, you would want to also provide a
consumer of that API to illustrate how this is used.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
