From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 06/17] net: dsa: Move port device node into port
 structure
Date: Fri, 3 Jun 2016 11:21:36 -0700
Message-ID: <5751CAB0.8040208@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36502 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbcFCSVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:21:39 -0400
Received: by mail-pa0-f51.google.com with SMTP id te7so13189316pab.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:21:38 -0700 (PDT)
In-Reply-To: <1464972256-10408-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> Move the port device node structure into the port structure, from the
> chip data. This information is needed in the next step of implementing
> the new binding.
> 
> The chip data structure is used while parsing the whole old binding,
> before the individual switch structures exist. With the new bindings,
> this is reversed, the switches exist first, and the interconnections
> between the switches is derived from the individual switch
> bindings. Thus this chip data structure becomes unneeded.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
