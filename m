From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for Mediatek MT7530 switch
Date: Thu, 25 May 2017 22:54:32 -0700
Message-ID: <043CDC76-3C57-4F54-97B6-896591A11CB3@gmail.com>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com> <1490780303-18598-6-git-send-email-sean.wang@mediatek.com> <hn6gvd-qp1.ln1@banana.localnet>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: "Andrey Jr. Melnikov" <temnota.am-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <hn6gvd-qp1.ln1-f2MyMQbBE8IG/9ncUZ6upg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On May 24, 2017 4:17:39 AM PDT, "Andrey Jr=2E Melnikov" <temnota=2Eam@gmail=
=2Ecom> wrote:
>In gmane=2Elinux=2Ekernel sean=2Ewang@mediatek=2Ecom wrote:
>> From: Sean Wang <sean=2Ewang@mediatek=2Ecom>
>
>> MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
>> Mediatek router platforms such as MT7623A or MT7623N platform which
>> includes 7-port Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY=2E
>> Among these ports, The port from 0 to 4 are the user ports connecting
>> with the remote devices while the port 5 and 6 are the CPU ports
>> connecting into Mediatek Ethernet GMAC=2E
>
>> For port 6, it can communicate with the CPU via Mediatek Ethernet
>GMAC
>> through either the TRGMII or RGMII which could be controlled by
>phy-mode
>> in the dt-bindings to specify which mode is preferred to use=2E And for
>> port 5, only RGMII can be specified=2E However, currently, only port 6
>is
>> being supported in this DSA driver=2E
>
>> The driver is made with the reference to qca8k and other existing DSA
>> driver=2E The most of the essential callbacks of the DSA are already
>> support in the driver, including tag insert for user port
>distinguishing,
>> port control, bridge offloading, STP setup and ethtool operation to
>allow
>> DSA to model each user port into a standalone netdevice as the other
>DSA
>> driver had done=2E
>
>What about JUMBO frames and large MTU support? devlink support?

We don't have a ndo_change_mtu callback implemented for DSA network device=
s but that is probably how we should do it=2E Regarding devlink, Andrew add=
ed basic support for it but unlike mlxsw it is currently of mild interest=
=2E Do you have something specific in mind with devlink?

--=20
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
