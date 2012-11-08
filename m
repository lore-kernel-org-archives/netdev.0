From: Ian Coolidge <iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 0/2] Fix CDC_EEM with 802.1Q VLAN and 1500 MTU
Date: Wed,  7 Nov 2012 16:39:17 -0800
Message-ID: <1352335159-8049-1-git-send-email-iancoolidge@gmail.com>
Cc: Ian Coolidge <iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

cdc_eem USB host driver and gadget driver both are broken in 1500 MTU
case while using 802.1Q VLANs. In both cases, this is due to the
assumption of standard Ethernet frame length.

v2: rebase against Dave Miller's 'net/master' tree

Ian Coolidge (2):
  usb: gadget: g_ether: fix frame size check for 802.1Q
  net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs

 drivers/net/usb/cdc_eem.c    |    3 ++-
 drivers/usb/gadget/u_ether.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

-- 
1.7.6.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
