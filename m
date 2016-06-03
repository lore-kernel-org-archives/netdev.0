From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 01/17] net: dsa: slave: chip data is optional,
 don't dereference NULL
Date: Fri, 3 Jun 2016 10:16:20 -0700
Message-ID: <5751BB64.30103@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36486 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232AbcFCRQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:16:23 -0400
Received: by mail-pf0-f180.google.com with SMTP id f144so45552903pfa.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:16:23 -0700 (PDT)
In-Reply-To: <1464972256-10408-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> The new binding does not make use of dsa_chip_data, a.k.a cd.  When
> retrieving the size of the EEPROM attached to a switch, don't assume
> there is a cd attached to the switch structure.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
