From: "Jan Beulich" <JBeulich@novell.com>
Subject: net_device leak after "bridge: allow creating bridge devices
	 with netlink"?
Date: Mon, 22 Aug 2011 12:34:18 +0100
Message-ID: <4E525ADA020000780005278A@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

directly returning the result of register_netdev() from br_add_bridge()
would - to me - appear to be leaking "dev" in case of failure. Or am I
overlooking some implicit mechanism by which this would get freed?

Thanks, Jan


