From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: difference in counters values between vlan and parent device
Date: Mon, 29 Jun 2009 18:05:06 +0300
Message-ID: <4A48D822.6020100@Voltaire.com>
References: <Pine.LNX.4.64.0906291654310.27208@zuben.voltaire.com> <4A48D191.9020903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:10653 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756997AbZF2PFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 11:05:11 -0400
In-Reply-To: <4A48D191.9020903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> So the average packet size is 56 bytes on eth1 and 42 bytes
> on eth1.4001. So the difference is 14 bytes, which is expected
> since the mac header is pulled off before delivery to the VLAN device.

yes makes sense... I am using 22 bytes for netperf payload which without VLAN produces 64=22+8+20+14 bytes frames (8 bytes for UDP header, 20 bytes for IP header, 14 bytes for Eth header). Now with vlans, how many bytes are on the wire, 78=64+14 ?


Or.
