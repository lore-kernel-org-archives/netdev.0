From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] VLAN: kill_vid is only useful for VLAN filtering
 devices
Date: Sun, 03 Jun 2007 11:47:34 -0400
Message-ID: <4662E296.5010505@garzik.org>
References: <20070601164356.673375550@linux-foundation.org> <20070601164705.300415731@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38287 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbXFCPrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:47:42 -0400
In-Reply-To: <20070601164705.300415731@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The interface for network device VLAN extension was confusing.
> The kill_vid function is only really useful for devices that do
> hardware filtering. Devices that only do VLAN receiption without
> filtering were being forced to provide the hook, and there were
> bugs in those devices.
> 
> Many drivers had kill_vid routine that called vlan_group_set_device, with
> NULL, but that is done already.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-5 to #upstream-fixes


