From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: setting flow spec rules under vswitch configuration
Date: Tue, 9 Oct 2012 11:37:55 +0200
Message-ID: <5073F073.3060403@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:51989 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751440Ab2JIJlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 05:41:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Looking on kernel ethtool flow steering APIs in the context of a device
which is used as the uplink of a virtual switch, the admin should be able
to provide flow specification and action (e.g drop) that relates to traffic
coming from a specific port of the switch e.g that relates to a certain 
VM,etc.

For that end, we need to be able to specify both the L3/L4 attributes of
the flow and an L2 spec, that is the L2 spec containing the destination MAC
can't be assumed as the one of that device.

Specifically, in struct ethtool_rx_ntuple_flow_spec, I think we should 
let the
to provide an ethhdr even when L3/L4 spec is given, make sense? if yes, how
would you like to see this change, add a union entry that contains both, 
or in
another way?

Or.
