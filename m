From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCHv2] net: Define enum for the bits used in features.
Date: Wed, 25 May 2011 09:58:51 +0200
Message-ID: <c98e3c64d35f369c7c98ffff3dd2d025@localhost>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
 <1306288567-1773-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57618 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932114Ab1EYH6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 03:58:52 -0400
In-Reply-To: <1306288567-1773-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 24 May 2011 18:56:07 -0700, Mahesh Bandewar wrote:

> Little bit cleanup by defining enum for all bits used. Also use those

enum

> values to redefine flags.



Where is the advantage? Now I need to add 2 lines at two different places.



#define NETIF_F_IP_CSUM		BIT2FLAG(IP_CSUM_BIT)



Confuses me more compared to a simple 



#define NETIF_F_IP_CSUM		(1 << 2)





The enum netdev_features namespace is not really unique (e.g.

RESERVED16_BIT).





For me the modifications are harder to understand, my tools are confused

and I see no real advantage, only more indirection introduced.





Hagen
