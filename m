From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/3] net: dsa: Use devm_ prefixed allocations
Date: Fri, 2 Oct 2015 15:25:09 +0200
Message-ID: <560E85B5.8090208@openwrt.org>
References: <560E60E4.8020706@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:50372 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbbJBNZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 09:25:15 -0400
In-Reply-To: <560E60E4.8020706@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-10-02 12:48, Neil Armstrong wrote:
> To simplify and prevent memory leakage when unbinding, use
> the devm_ memory allocation calls.
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
I think you also need to get rid of the corresponding free calls in the
error path, otherwise it will probably crash at some point.

- Felix
