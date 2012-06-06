From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next] fec: Add support for Coldfire M5441x enet-mac.
Date: Wed, 06 Jun 2012 19:34:21 +0200
Message-ID: <4FCF949D.7060402@computer.org>
References: <201206061006.21288.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	uClinux development list <uclinux-dev@uclinux.org>,
	Greg Ungerer <gerg@snapgear.com>
To: Steven King <sfking@fdwdc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:46309 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752173Ab2FFRfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:35:07 -0400
In-Reply-To: <201206061006.21288.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2012 07:06 PM, Steven King wrote:
> Add support for the Freescale Coldfire M5441x; as these parts have an 
> enet-mac, add a quirk to distinguish them from the other Coldfire parts so we 
> can use the existing enet-mac support.

Stephen,

You are activating certain functionality based on whether M5441x is
defined. But where is this being defined? Should this not be added in a
Kconfig somewhere as a platform option?

Thanks, Jan
