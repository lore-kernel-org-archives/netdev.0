From: raj ravi <mekaviraj@gmail.com>
Subject: NETIF_F_FRAGLIST and NETIF_F_SG difference
Date: Mon, 1 Mar 2010 16:32:17 +0530
Message-ID: <de0a9dcb1003010302p2f81aa17ubdbb29bb007d50cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:44422 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab0CALCS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 06:02:18 -0500
Received: by vws10 with SMTP id 10so322836vws.19
        for <netdev@vger.kernel.org>; Mon, 01 Mar 2010 03:02:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
http://lxr.linux.no/#linux+v2.6.33/include/linux/netdevice.h
In include/linux/netdevice.h I can see two definiton for "Scatter
Gather IO" namely NETIF_F_FRAGLIST =A0and NETIF_F_SG

Please let me know the difference between the two.... if there is no
difference why two Macros ??


#define NETIF_F_SG 1 /* Scatter/gather IO. */
#define NETIF_F_IP_CSUM 2 /* Can checksum TCP/UDP over IPv4. */
#define NETIF_F_NO_CSUM 4 /* Does not require checksum. F.e. loopack. *=
/
#define NETIF_F_HW_CSUM 8 /* Can checksum all the packets. */
#define NETIF_F_IPV6_CSUM 16 /* Can checksum TCP/UDP over IPV6 */
#define NETIF_F_HIGHDMA 32 /* Can DMA to high memory. */
#define NETIF_F_FRAGLIST 64 /* Scatter/gather IO. */

Thx!
Kavi
