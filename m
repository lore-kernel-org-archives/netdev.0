From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 10:15:11 +0100
Message-ID: <200702211015.11975.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com> <20070221085406.GB1903@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52545 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161152AbXBUJPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 04:15:22 -0500
In-Reply-To: <20070221085406.GB1903@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 21 February 2007 09:54, Evgeniy Polyakov wrote:
> I shown that numbers 4 times already, do you read mails and links?
> Did you see an artifact Eric showed with his data?
>

I showed all your thinking is wrong.

Some guys think MD5 checksum is full of artifacts, since its certainly 
possible to construct two differents files having the same md5sum.
Yet, lot of people use md5 checksums. In 10 years, we probably switch to 
another stronger hash. Its only a question of current state of the art.

Jenkins hash is far better than XOR, at least in the tcp ehash context.

Some hackers already exploited the XOR hash weak, more than two years ago.
They never succeeded since I changed to Jenkins hash.

