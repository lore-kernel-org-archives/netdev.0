From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback mode.
Date: Tue, 04 Jan 2011 17:34:29 -0800
Message-ID: <4D23CAA5.7060902@hp.com>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>	<1294187401-4662-1-git-send-email-maheshb@google.com>	<20110104163645.0b3a3687@nehalam>	<1294190504.2992.3.camel@localhost> <20110104172939.711b758d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:8987 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab1AEBed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 20:34:33 -0500
In-Reply-To: <20110104172939.711b758d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>Since this is a boolean it SHOULD go into ethtool_flags rather than
>>>being a high level operation.
>>
>>It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
>>controlling offload features.
> 
> 
> It just seems the number of hooks keeps growing which takes more space
> and increases complexity.

Is there any complication/downside to using flags in the (un?)likely event of 
wanting different flavors of loopback in the card?

rick jones
