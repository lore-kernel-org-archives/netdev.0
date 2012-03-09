From: Imre Keri <sharp732@gmail.com>
Subject: make sanity checks in ipv6 tunneling device optional?
Date: Fri, 9 Mar 2012 11:56:05 +0100
Message-ID: <CAFs3Y4rhutu7WvmrdD-544RAw2H377dTBH97zgHe0YYfgmR5ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:39312 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753557Ab2CIK4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 05:56:06 -0500
Received: by obbuo6 with SMTP id uo6so1983798obb.19
        for <netdev@vger.kernel.org>; Fri, 09 Mar 2012 02:56:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I want to use IPv6 tunnels to create a one-directional all-to-all
connection (fully connected network) between many nodes. Instead of
creating a separate tunnel device on every node to each destination I
would like to create one single tunnel device on each node and route
the tunneled packets based on fwmark value to the correct destination.
Thus one tunnel device can act as many tunnels. I can not get this
system to work because the tunneling devices are prohibing tunnels
where the remote endpoint is a local address of the node
(ip6_tnl_xmit_ctl() function). Do you accept a patch which makes this
check optional?

Imre
