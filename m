From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 17:01:29 -0700
Message-ID: <20060414000129.GB23116@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:9856 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1751166AbWDNABc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 20:01:32 -0400
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote :
> 
> Sounds like you want a message interface like netlink, not ioctl's.

	We have the message interface (through a Wireless Events,
since WE-14). However, netlink is highly undesirable in embedded space
for bloat reason.

	Jean
