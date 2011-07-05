From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 10:48:07 +0200
Message-ID: <4E12CFC7.3070902@inliniac.net>
References: <1309849214.2720.45.camel@edumazet-laptop> <20110705.005011.1268380726966376331.davem@davemloft.net> <4E12C2B2.9060007@inliniac.net> <20110705.010254.1376215864913143868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:39364 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab1GEIsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 04:48:35 -0400
In-Reply-To: <20110705.010254.1376215864913143868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 10:02 AM, David Miller wrote:
> Would you prefer to receive the frags individually?

Ideally what we receive is the same as on the wire, but I think your
solution would be fine.

In addition to the reassembled packet, having an option to receive the
individual frags as well would be of use. Suricata (and Snort as well)
has it's own defrag code that does anomaly detection. I can see a use
case where just for that anomaly detection we'd still want to see the
frags. In that case it wouldn't be a problem that they would all go to
fanout 0.

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

