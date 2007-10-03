From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [9/11] pasemi_mac: clear out old errors on interface
 open
Date: Wed, 03 Oct 2007 13:46:16 -0400
Message-ID: <4703D568.6000000@pobox.com>
References: <20071002212421.GA2282@lixom.net> <20071002212739.GJ2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53369 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587AbXJCRqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 13:46:23 -0400
In-Reply-To: <20071002212739.GJ2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> pasemi_mac: clear out old errors on interface open
> 
> Clear out any pending errors when an interface is brought up. Since the bits
> are sticky, they might be from interface shutdown time after firmware has
> used it, etc.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

In general, interface-open should completely reset and initialize the 
hardware.  does pasemi_mac not do that?

	Jeff



