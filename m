From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Thu, 5 Mar 2015 11:13:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAF571E@AcuExch.aculab.com>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Tom Herbert' <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"fw@strlen.de" <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:57621 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229AbbCELPD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 06:15:03 -0500
In-Reply-To: <1425494404-24114-1-git-send-email-therbert@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert
...
> - The probability that two different flows randomly match to the same
>   hash from skb_get_hash is 1/2^32. If such a collision were to happen,
>   then the flows potentially also map to the same qdisc queue in
>   perpetuity despite perturbation being performed. Given the very low
>   probability of this occurring, this may in practice only be an
>   academic issue. If it is a real concern, rekeying of the underlying
>   mechanisms of skb->hash could be done.
...

The probability of a collision is much higher than that.
With 10000 flows it is (if my 'ballpark maths' is right) nearer 1/100.

	David
