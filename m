From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 0/6] sky2 driver update (v1.11)
Date: Tue, 26 Dec 2006 16:44:24 -0500
Message-ID: <459197B8.6010403@pobox.com>
References: <20061220210632.183204605@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41616 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932813AbWLZVo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:44:26 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061220210632.183204605@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Patches are in order of severity. 1-3 are bug fixes, 4 is a cleanup
> of the power state code, and 5 adds wake on lan support.
> 
> IMHO, it is bad security policy to allow wake on lan to enabled by default.
> The sky2 driver doesn't do WOL until enabled with ethtool.

While in general I agree with you on the security principle, this seems 
like it might break working setups.

WOL is a partnership between the motherboard and NIC.  The motherboard 
must support WOL, or its useless.  And since the motherboard must 
support WOL, it normally has an on/off switch in BIOS.

As such, you're overriding the admin's chosen BIOS setting here.

	Jeff



