From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 3/4] phy: Add USB3 PHY support for Broadcom NSP SoC
Date: Thu, 2 Feb 2017 07:48:35 +0100
Message-ID: <6be62ef6-e90c-b5f8-adcd-0ea62ab73ced@gmail.com>
References: <1484669670-4201-4-git-send-email-yendapally.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Ray Jui <rjui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Scott Branden <sbranden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Jon Mason <jonmason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1484669670-4201-4-git-send-email-yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[Resending with fixed/complete Cc-s]

On Tue, 17 Jan 2017 11:14:29 -0500, Yendapally Reddy Dhananjaya Reddy <yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:> This patch adds support for Broadcom NSP USB3 PHY
 >
 > Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

Seriously?! I really dislike what you did there.

NACK.

You are aware this block is common for both: Northstar and Northstar Plus and
we already have phy-bcm-ns-usb3.c! In fact Jon told me to rewrite my initial
driver to make is possible to reuse it on NSP and I did that!

This is old comment from Jon:

In 30 March 2016 at 23:31, Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
 > On Mon, Mar 28, 2016 at 9:46 PM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 > wrote:
 >>
 >> CC: bcm-kernel-feedback-list, Jon
 >
 >
 > This is a common IP block with NSP.  I believe with some minor changes it
 > can support both.  Please allow me 1-2 days to look at these in more detail
 > and see if I can get these patches working on NSP.

Please start using existing code instead of inventing everything from the
scratch internally at Broadcom. You did the same thing with (Q)SPI driver.


This driver duplicates phy-bcm-ns-usb3.c and should have not been accepted. I
strongly suggest *reverting* it and adjusting existing driver if needed.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
