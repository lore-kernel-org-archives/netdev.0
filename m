From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] ibmveth: Enable TCP checksum offload
Date: Fri, 31 Aug 2007 09:32:17 -0400
Message-ID: <46D81861.3010003@garzik.org>
References: <11873601831813-patch-mail.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43265 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965030AbXHaNcT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:32:19 -0400
In-Reply-To: <11873601831813-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> This patchset enables TCP checksum offload support for IPV4
> on ibmveth. This completely eliminates the generation and checking of
> the checksum for packets that are completely virtual and never
> touch a physical network. A simple TCP_STREAM netperf run on
> a virtual network with maximum mtu set yielded a ~30% increase
> in throughput. This feature is enabled by default on systems that
> support it, but can be disabled with a module option.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

applied 1-6


