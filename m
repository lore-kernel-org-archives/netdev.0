From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: private netdev flags into UAPI?
Date: Sun, 25 Nov 2012 09:43:23 +0200
Message-ID: <50B1CC1B.20104@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:38024 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751366Ab2KYHn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 02:43:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

not sure if this has been brought up before, but I realized that the 
private IFF_yyy netdevice flags which weren't exposed to user space so 
far have been moved to include/uapi/linux/if.h, isn't that wrong?

Or.

> /* Private (from user) interface flags (netdevice->priv_flags). */
> #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
> #define IFF_EBRIDGE     0x2             /* Ethernet bridging device.    */
> [...]                                  * change when it's running */
