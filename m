From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [net-2.6 PATCH 1/3] be2net: Bug fix to avoid soft lockup in loopback
 test.
Date: Thu, 24 Dec 2009 14:28:53 +0100
Message-ID: <4B336C95.2050808@computer.org>
References: <20091223144026.GA23383@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:62791 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750998AbZLXNda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 08:33:30 -0500
In-Reply-To: <20091223144026.GA23383@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sarveshwar Bandi wrote:
> This change ensures that loopback test command gives up after 4 seconds when 
> the hardware is not responsive. This could happen if the ports are connected 
> properly in loopback mode.

I don't understand the 2nd sentence, did you mean to say that this could happen if the ports are *not* connected properly in loopback mode?

Thanks, Jan
