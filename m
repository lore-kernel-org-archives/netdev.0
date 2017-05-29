From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Mon, 29 May 2017 17:29:26 +0200
Message-ID: <20170529152926.GA21315@lunn.ch>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
 <1490780303-18598-6-git-send-email-sean.wang@mediatek.com>
 <hn6gvd-qp1.ln1@banana.localnet>
 <043CDC76-3C57-4F54-97B6-896591A11CB3@gmail.com>
 <CA+PODjoZpYLVKCXveUGvu8MXX4YVmE-bKm241o_3OT3P5pkieQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Andrey Melnikov <temnota.am-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+PODjoZpYLVKCXveUGvu8MXX4YVmE-bKm241o_3OT3P5pkieQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I want to see each ports behind the bridge as independent ethernet
> devices. If I understand RTFM only devlink may expose this
> configuration.

DSA and switchdev in general gives you a linux interface per user
switch port. So you can see each interface, get stats, ethtools,
mii-tool, etc per interface. devlink is not needed for this.

	  Andrew

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
