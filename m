From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Tue, 31 Mar 2015 16:49:23 -0400 (EDT)
Message-ID: <20150331.164923.229749666073516444.davem@davemloft.net>
References: <1427718657-21674-1-git-send-email-klamm@yandex-team.ru>
	<20150331.160538.1808487957641759931.davem@davemloft.net>
	<1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klamm@yandex-team.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 31 Mar 2015 22:35:48 +0200

> Could you quickly comment on what you had in mind? I guess it is about
> handling RA in user space on the end hosts and overwriting MTU during
> insertion of the routes?

Even after reading your email I have no idea why you can't just have
RA provide a 1500 byte MTU, everything else uses the device's 9000
MTU, problem solved?
