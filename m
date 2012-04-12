From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH 4/5] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 19:56:38 +0200
Message-ID: <4F871756.80002@computer.org>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com> <1334248375-22967-5-git-send-email-greearb@candelatech.com> <4F8705E3.2010902@openwrt.org> <4F870828.4020708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:29576 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932108Ab2DLR5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 13:57:01 -0400
In-Reply-To: <4F870828.4020708@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Ethtool stats only supports u64. I think it's easy enough for
> humans or programs to add the negative sign. Can signal or noise
> ever be > 0? If so, that could actually break something that depends
> on flipping the value to negative....

The unit of these quantities is dBm, right? So if the {signal|noise} is 
greater than 1mW the corresponding value in dBm would be positive.
