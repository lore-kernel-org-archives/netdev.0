From: Kostya B <bkostya@hotmail.com>
Subject: netif_needs_gso behavior
Date: Tue, 15 Apr 2008 16:52:20 +0000
Message-ID: <BAY121-W4698632384BFB6587EAB45B6EB0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s21.bay0.hotmail.com ([65.54.246.93]:20256 "EHLO
	bay0-omc1-s21.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754163AbYDOQwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 12:52:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

Please help me to understand why !=3D CHECKSUM_PARTIAL packet requires =
gso? In the case of TCP it is ok, however UDP could be normally uncheck=
ed.

netif_needs_gso()=20
{
 	return skb_is_gso(skb) &&
 	       (!skb_gso_ok(skb, dev->features) ||
 		unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL));
}

Thanks
_________________________________________________________________
Connect to the next generation of MSN Messenger=A0
http://imagine-msn.com/messenger/launch80/default.aspx?locale=3Den-us&s=
ource=3Dwlmailtagline
