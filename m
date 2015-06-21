From: Markus Stenberg <markus.stenberg@iki.fi>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Sun, 21 Jun 2015 23:05:00 +0100
Message-ID: <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi> <5586F1F8.1070800@universe-factory.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Steven Barth <steven@midlink.org>
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5586F1F8.1070800@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefsrc is essentially historic non IPv6 construct. IPv6 SAS is based on dst, src, metric ordered lookup just like the routing is too ( lookup rfc, some src specific routing drafts for details ). 

Therefore I do not see a problem. If you want specific SA, add same route with higher metric and/or (more) specific src match. 

There might be bugs there tho, but that is how it should work. As SAS is supposed to happen before routing ( see rfc ) the prefsrc is .. Cough.

-Markus
