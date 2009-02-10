From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netdevice: ticks reaches 25, not 26.
Date: Tue, 10 Feb 2009 08:50:21 +0000
Message-ID: <20090210085021.GB4190@ff.dom.local>
References: <20090209.175714.70463534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:64433 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140AbZBJIu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 03:50:28 -0500
Content-Disposition: inline
In-Reply-To: <20090209.175714.70463534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-02-2009 02:57, David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Mon, 09 Feb 2009 23:22:11 +0100
> 
>> With while (tick++ < 25) { ... } ticks reaches 25, not 26.
> 
> Does it?
> 
> --------------------
> #include <stdio.h>
> int main(void)
> {
> 	int i = 0;
> 	while (i++ < 25)
> 		;
> 	printf("%d\n", i);
> 
> 	return 0;
> }
> --------------------
> davem@sunset:~/src/GIT/linux-2.6$ gcc -O2 -o x x.c
> davem@sunset:~/src/GIT/linux-2.6$ ./x
> 26
> davem@sunset:~/src/GIT/linux-2.6$ 
> 
> I'm getting extremely tired of these "off by one" patches, to be
> honest with you.

So, what other C feature do you find a better source of joy now?

Jarek P.
