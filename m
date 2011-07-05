From: Mikhail Paremski <mparemm@gmail.com>
Subject: IPv6 destination cache in Linux kernel
Date: Mon, 4 Jul 2011 17:35:04 -0700
Message-ID: <CF5C0F47-9A82-44CF-8441-AC23C26E476B@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51229 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847Ab1GEAfG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 20:35:06 -0400
Received: by pvg12 with SMTP id 12so4722019pvg.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 17:35:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm trying to understand how Linux kernel routes IPv6 datagrams. It looks it does it much different from IPv4. While IPv4 uses Destination cache to find out what is the destination IP, MAC and interface index to send packet out, in IPv6 case it uses some destination tree to do that. It also  does not uses that tree in case, if destination address is not on a local network. Is it correct?So, I have a few questions:

1. What are the reasons to rout datagrams differently fromIPv4?
2. Where I could get details how IPv6 stack routes datagrams?
3. Are there around books like "IPv6 Core Protocols Implementation" but with Linux specific details?
4. Any other sources of information about this topic?

Thank you very much,
Mikhail. 