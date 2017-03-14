From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] dt-bindings: net: dsa: add Mediatek MT7530
 binding
Date: Tue, 14 Mar 2017 12:58:06 +0100
Message-ID: <20170314115806.GS15842@lunn.ch>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-2-git-send-email-sean.wang@mediatek.com>
 <928d1178-e04a-3e78-4a7a-36127321a949@gmail.com>
 <1489474323.1870.47.camel@mtkswgap22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489474323.1870.47.camel@mtkswgap22>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> By the ways, I have a question which is could current DSA framework
> allows managing the fabric designated from "multiple cpu ports" to "user
> ports" in any combination in brctl and in other existing commands?
> 
> For example.
> 
> I assume that there are two cpu port called 5, and 6.and there are five
> user ports called 0, 1, 2 and 3. and the default fabric on the switch is
> mapping from { 5 } <-> { 0, 1, 2, 3 ,4 } where members in the braces I
> assumes they also can communicate with each other.
> 
> Is it feasible for changing the fabric into other combinations in the
> runtime such as 
> {5} <-> {0, 1, 2, 3} and {6} <-> {4}
> {5} <-> {0, 1, 2} and {6} <-> {3, 4} or 
> {6} <-> {0, 1} and {6} <-> {2, 3, 4} or
> ....
> {6} <-> {0, 1, 2, 3 ,4} ?
> 
> After some trace code, I found it seemed that only one cpu port could be
> supported via one dsa registration. 

Hi Sean

This is on our TODO list, and getting near the top of Florians list,
as far as i understand. A few years ago i did make a proof of concept
implementation for this, and the new device tree binding was designed
with this in mind.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
