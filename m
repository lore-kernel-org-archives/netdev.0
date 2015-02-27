From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] wireless: test sscanf return values
Date: Fri, 27 Feb 2015 10:35:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAF0B29@AcuExch.aculab.com>
References: <1425015791.2690.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: 'Joe Perches' <joe@perches.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425015791.2690.7.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches
> At some point, it'd be good to make sscanf use __must_check
> so make sure the net/ uses of sscanf use the return value.

Isn't it much safer to avoid sscanf() completely and use
a different function for converting numerics?

	David
