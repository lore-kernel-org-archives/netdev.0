From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 20:52:55 +0200
Message-ID: <5526CA87.2070204@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:43881 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932841AbbDISxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 14:53:07 -0400
In-Reply-To: <5526B608.2080504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:

> Mason wrote:
>
>> Is speed auto-negotiation supposed to be complete when phy_init_hw exits?
> 
> There is no such guarantee, and the PHY state machine is started later,
> which will take care of auto-neg and other things.

That's what I thought.

So it's expected that many status bits will only change later.

You didn't comment on my patch. What's your take on it?

Regards.
