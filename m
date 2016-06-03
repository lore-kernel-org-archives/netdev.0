From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 09/17] net: dsa: Split up creating/destroying of
 DSA and CPU ports
Date: Fri, 3 Jun 2016 14:21:12 -0700
Message-ID: <5751F4C8.5040009@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-10-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34680 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbcFCVVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:21:15 -0400
Received: by mail-pf0-f178.google.com with SMTP id 62so47231470pfd.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:21:14 -0700 (PDT)
In-Reply-To: <1464972256-10408-10-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> Refactor the code to setup a single DSA/CPU port into a function of
> its own, and export it, so it can be used by the new binding.
> 
> Similarly, refactor the destroy code into a function.  When destroying
> the ports, don't put the of node. They should be released at the end
> along with the normal ports.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
