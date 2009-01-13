From: "Tekale Sharad-FHJN78" <FHJN78@motorola.com>
Subject: Vlan help
Date: Tue, 13 Jan 2009 13:34:51 +0800
Message-ID: <E9E3926FA9CDBF489EA1684042C8A0260103776B@zmy16exm72.ds.mot.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail119.messagelabs.com ([216.82.241.195]:54600 "HELO
	mail119.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752280AbZAMFfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:35:02 -0500
Received: from il27exr04.cig.mot.com (il27exr04.mot.com [10.17.196.73])
	by motgate4.mot.com (8.12.11/Motorola) with ESMTP id n0D5Z0fc019968
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 22:35:00 -0700 (MST)
Received: from il27vts01 (il27vts01.cig.mot.com [10.17.196.85])
	by il27exr04.cig.mot.com (8.13.1/Vontu) with SMTP id n0D5Z09T004930
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 23:35:00 -0600 (CST)
Received: from zmy16exm72.ds.mot.com (zmy16exm72.ap.mot.com [10.179.4.45])
	by il27exr04.cig.mot.com (8.13.1/8.13.0) with ESMTP id n0D5YwpC004921
	for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 23:34:59 -0600 (CST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hi,

I have a query,

I'm trying to configure port based vlan on fonera2201(5 ports) device.

I have enabled debugging in 802q/vlan.c( Kernel version 2.6.21.5 ), I
can see the interfaces created properly, but following message is
continuously displayed on console
 
vlan_skb_recv: ERROR: No net_device for VID: 103 on dev: eth0.1 [5]
vlan_skb_recv: skb: 8122f440 vlan_id: 67
vlan_skb_recv: ERROR: No net_device for VID: 103 on dev: eth0.1 [5]
vlan_skb_recv: skb: 8121eee0 vlan_id: 67
vlan_skb_recv: ERROR: No net_device for VID: 103 on dev: eth0.1 [5]
vlan_skb_recv: skb: 81115e20 vlan_id: 67
vlan_skb_recv: ERROR: No net_device for VID: 103 on dev: eth0.1 [5]
vlan_skb_recv: skb: 8106dbc0 vlan_id: 67

When user adds (vlan port numbers)details in /etc/config/network file,

How does switch driver gets invoked and configures the ports to
different vlans?

Sorry for my basic question, but I'm trying to understand the flow?

I'm unable to link, how does 8021q/vlan.c speak with either
dsa/mv88e6*(or any other switch driver to configure vlan ports.)

Thanks In Advance,
Sharad.
