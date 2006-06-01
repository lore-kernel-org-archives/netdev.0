From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Thu, 1 Jun 2006 00:18:25 -0600
Message-ID: <20060601001825.A21730@openss7.org>
References: <20060531090301.GA26782@2ka.mipt.ru> <20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru> <20060531.114127.14356069.davem@davemloft.net> <20060601060424.GA28087@2ka.mipt.ru>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:53394 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S1751813AbWFAGS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 02:18:27 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060601060424.GA28087@2ka.mipt.ru>; from johnpol@2ka.mipt.ru on Thu, Jun 01, 2006 at 10:04:24AM +0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

On Thu, 01 Jun 2006, Evgeniy Polyakov wrote:
> 	
> 	for (i=0; i<hash_size*iter_num; ++i) {
> 		saddr = num2ip(get_random_byte(), get_random_byte(), get_random_byte(), get_random_byte());
> 		sport = get_random_word();

You still have a problem: you cannot use a pseudo-random number
generator to generate the sample set as the pseudo-random number
generator function itself can interact with the hash.

Try iterating through all 2**48 values or at least a sizeable
representative subset.

