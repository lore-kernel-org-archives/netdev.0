From: Andrey Melnikov <temnota.am-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Mon, 29 May 2017 13:44:15 +0300
Message-ID: <CA+PODjoZpYLVKCXveUGvu8MXX4YVmE-bKm241o_3OT3P5pkieQ@mail.gmail.com>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
 <1490780303-18598-6-git-send-email-sean.wang@mediatek.com>
 <hn6gvd-qp1.ln1@banana.localnet>
 <043CDC76-3C57-4F54-97B6-896591A11CB3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <043CDC76-3C57-4F54-97B6-896591A11CB3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-05-26 8:54 GMT+03:00 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On May 24, 2017 4:17:39 AM PDT, "Andrey Jr. Melnikov" <temnota.am-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>In gmane.linux.kernel sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
>>> From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
>>
>>> MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
>>> Mediatek router platforms such as MT7623A or MT7623N platform which
>>> includes 7-port Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY.
>>> Among these ports, The port from 0 to 4 are the user ports connecting
>>> with the remote devices while the port 5 and 6 are the CPU ports
>>> connecting into Mediatek Ethernet GMAC.
>>
>>> For port 6, it can communicate with the CPU via Mediatek Ethernet
>>GMAC
>>> through either the TRGMII or RGMII which could be controlled by
>>phy-mode
>>> in the dt-bindings to specify which mode is preferred to use. And for
>>> port 5, only RGMII can be specified. However, currently, only port 6
>>is
>>> being supported in this DSA driver.
>>
>>> The driver is made with the reference to qca8k and other existing DSA
>>> driver. The most of the essential callbacks of the DSA are already
>>> support in the driver, including tag insert for user port
>>distinguishing,
>>> port control, bridge offloading, STP setup and ethtool operation to
>>allow
>>> DSA to model each user port into a standalone netdevice as the other
>>DSA
>>> driver had done.
>>
>>What about JUMBO frames and large MTU support? devlink support?
>
> We don't have a ndo_change_mtu callback implemented for DSA network devices but that is probably how we should do it.
> Regarding devlink, Andrew added basic support for it but unlike mlxsw it is currently of mild interest. Do you have something specific in mind with devlink?

I want to see each ports behind the bridge as independent ethernet
devices. If I understand RTFM only devlink may expose this
configuration.
