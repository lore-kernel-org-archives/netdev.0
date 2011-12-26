From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH 1/2] bna: Added flash sub-module and ethtool eeprom entry
 points.
Date: Mon, 26 Dec 2011 13:02:27 +0100
Message-ID: <4EF86253.3010108@computer.org>
References: <1324596585-8614-1-git-send-email-kgudipat@brocade.com>	 <1324633462.3860.6.camel@deadeye>	 <B5EE62D80D50B84BB9E5174F7FCCE80A206BE39A24@HQ1-EXCH02.corp.brocade.com> <1324721314.3860.11.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Gudipati <kgudipat@Brocade.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.com>,
	Rasesh Mody <rmody@Brocade.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:27668 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755310Ab1LZMHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 07:07:07 -0500
In-Reply-To: <1324721314.3860.11.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/2011 11:08 AM, Ben Hutchings wrote:
> I asked how long a single call would take, because the RTNL lock will be
> held for this time.  Presumably it doesn't take very long to write a 4K
> chunk, so this shouldn't be a problem.
>

461K is around 115 4K blocks. If these take around 3 minutes to flash 
then that's about 1.5s per 4K block.

Is it OK to hold the RTNL lock for that length of time?
