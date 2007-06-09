From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/4] NetXen: Fix ping issue after reboot on Blades with
 3.4.19 firmware
Date: Sat, 09 Jun 2007 18:26:17 -0400
Message-ID: <466B2909.5050202@garzik.org>
References: <200706071133.l57BX2G6007563@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35156 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426AbXFIW0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:26:19 -0400
In-Reply-To: <200706071133.l57BX2G6007563@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Fix initialization and subsequent ping issue on 3.4.19 firmware
> This patch fixes the ping problem seen X/PBlades after the adapter's 
> firmware was moved to 3.4.19. After configured interface up, ping 
> failed. 
> NetXen adapter couldn't accept ARP broadcast packet. Manual addition of
> MAC address in the ARP table, made ping work.
> NetXen adapter should finish initilization after system boot. But looks
> NetXen adapter didn't initilization correctly after system boot up.
> So have to re-load the firmware again in probe routine.
> Also re-initilization netxen_config_0 and netxen_config_1 registers.
> 
> Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

applied


