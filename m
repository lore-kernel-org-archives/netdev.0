From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.21.1] ipconfig: add support for multiple user devs
Date: Tue, 26 Jun 2007 23:45:12 -0700 (PDT)
Message-ID: <20070626.234512.69020584.davem@davemloft.net>
References: <1179429372.31146.31.camel@wcary0u3.ca.nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: skormilo@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758322AbXF0GwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 02:52:05 -0400
In-Reply-To: <1179429372.31146.31.camel@wcary0u3.ca.nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Sean Kormilo" <skormilo@nortel.com>
Date: Thu, 17 May 2007 15:16:12 -0400

> Update ipconfig to enable users to specify multiple devices on the kernel commandline
> ip= option. This allows for up-to 4 devices to be specified, with devices separated by 
> a '/' character.  For example, to limit autoconfig requests to eth0 and eth2:
> 	ip=:::::eth0/eth2:DHCP
> 
> This is required in cases where one might want to allow DHCP requests from multiple
> devices, but not necessarily want to broadcast on all ethernet devices that are present 
> in the system.

Hi Sean.  I have no objections to your patch, except that the
4 device limit seems arbitrary.

I would suggest to dynamically kmalloc() up a string buffer after
parsing the option string counting the "/" characters present.

That way there is no limit to the number of devices which can
be specified.

Please make this change and resubmit your patch so that I can
include it, thanks!
