From: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>
Subject: hard_start_xmit and Linux bridging
Date: Thu, 9 Sep 2004 17:10:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <FD52892BD296D71183B400065BFCB6900EDB4C74@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I tried going to the bridge@lists.osdl.org for this question but got no response, I'm hoping somebody here has had a similar experience as me.

Basically, I put my wlan0 driver in a bridge with eth0.  When my hard_start_xmit() function is called (as a result of a packet received on eth0 and bridged to my driver), the skb that I am passed contains an extra four bytes (e.g. the Ethernet FCS).  

In my mind, this should be stripped off.  But I have looked at all the open source net drivers I could find and nobody seems to care.  Is there a way to know if the skb has been forwarded by a bridged interface?  If I forward on the extra bytes, then a 1500 byte packet becomes 1504 and fails the MTU check on the other side of the wireless interface (when it is passed back to eth0).

TIA,
Adam
