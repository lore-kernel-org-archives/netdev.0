From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH 2.6.17 4/9] NetXen: intr routines and niu handling
Date: Mon, 21 Aug 2006 14:10:34 +0530
Message-ID: <200608211410.35076.amitkale@linsyssoft.com>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608180801340.6875@dut39> <20060818082206.54f193ff@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	jeff@garzik.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	rob@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:154 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1751151AbWHUIkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:40:53 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060818082206.54f193ff@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 August 2006 20:52, Stephen Hemminger wrote:
>
> Why keep track of statistics in one structure then copy out to net_device
> format? Instead just use original format.

net_device structure contains "unsigned long" fields. netxen_port_stats 
contains u64 fields. rx_bytes and tx_bytes can easily overflow for 10G cards.

ethtool_status contains u64 stats; is it a good time to make net_device_stats 
64 bit?

-Amit
