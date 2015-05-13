From: Joe Perches <joe@perches.com>
Subject: Re: qla3xxx: Odd likely incorrect use of test_bit in qla3xxx.c
Date: Wed, 13 May 2015 09:08:14 -0700
Message-ID: <1431533294.2912.8.camel@perches.com>
References: <1431456145.2884.75.camel@perches.com>
	 <20150513131908.GB8431@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0198.hostedemail.com ([216.40.44.198]:47079 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754475AbbEMQIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 12:08:17 -0400
In-Reply-To: <20150513131908.GB8431@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 16:19 +0300, Dan Carpenter wrote:
> I wrote a Smatch check to find similar bugs.

Nice.

It didn't look like something coccinelle could do and
I didn't know smatch syntax well enough (OK, I don't
know smatch syntax at all), to write something to find
these defects but I thought, if anyone, you could.

Thanks Dan for doing it.

> ath9k had memory corruption because they do:
> 	set_bit(BIT(6), &some_unsigned_long);
> Anyway, I'll send patches for the bugs I found and push the Smatch
> check.
