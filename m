From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver problems
Date: Tue, 04 Dec 2007 12:38:59 -0800
Message-ID: <4755BAE3.9090606@intel.com>
References: <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com> <20071204153405.GG8704@ics.muni.cz> <Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu> <20071204170827.GH8704@ics.muni.cz> <47558C0F.9000708@intel.com> <20071204195941.GJ8704@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Matt Mathis <mathis@psc.edu>, NetDev <netdev@vger.kernel.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11143 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704AbXLDUnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 15:43:06 -0500
In-Reply-To: <20071204195941.GJ8704@ics.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lukas Hejtmanek wrote:
> On Tue, Dec 04, 2007 at 09:19:11AM -0800, Kok, Auke wrote:
>> if you "just" want to disable gigabit speed, get the latest ethtool and run:
>>
>>    ethtool -s eth0 advertise 0x0f
>>
> 
> thanks. You may then let know people behind http://www.lesswatts.org/ to
> change tips&tricks related to the network. I turned off autonegotiation
> according to that web.

I have sent this out to them recently. This feature however is not available in
all drivers, they explicitly need to be able to handle the advertise mask flag,
and it requires a newer ethtool.

Cheers,

Auke
