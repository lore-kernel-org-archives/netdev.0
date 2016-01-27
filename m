From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Tue, 26 Jan 2016 16:33:11 -0800
Message-ID: <56A81047.4010802@gmail.com>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch> <1453853499-11248-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, aaro.koskinen@nokia.com,
	olof@lixom.net
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33627 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbcA0AeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 19:34:04 -0500
Received: by mail-pa0-f43.google.com with SMTP id cy9so106106267pac.0
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 16:34:03 -0800 (PST)
In-Reply-To: <1453853499-11248-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/16 16:11, Andrew Lunn wrote:
> PHY devices may only list clause 22, 45, and their PHY identifier
> values as compatible values. No other compatible strings are allowed.
> Make this clear in the documentation, and remove examples where
> make/model compatible strings are listed.

Humm, should not we rather require Ethernet PHY Device Tree nodes to
have *at least* a "ethernet-phy-ieee802.3-c22" or
"ethernet-phy-ieee802.3-c45", and any other compatible string which
further specifies the hardware is also welcome?

Do you think this deserves another commit when net-next opens up again?
-- 
Florian
