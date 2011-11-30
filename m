From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 22:15:10 -0700 (Mountain Standard Time)
Message-ID: <alpine.WNT.2.00.1111292212280.208@TSI>
References: <alpine.WNT.2.00.1111291027320.1036@TSI> <1322589661.2596.2.camel@edumazet-laptop> <1322599437.2596.10.camel@edumazet-laptop> <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com> <1322599991.2596.11.camel@edumazet-laptop>
 <alpine.WNT.2.00.1111291359290.1036@TSI> <1322601444.2596.21.camel@edumazet-laptop> <1322602283.2596.25.camel@edumazet-laptop> <CAL1RGDUcYJKBSCthTL1AFgpRvzjoaEpHjGFhratKP-98ufRKnw@mail.gmail.com> <alpine.WNT.2.00.1111291815410.1288@TSI>
 <CAL1RGDWzVRc4jFtsKUC6FGrdAWn3_OThXpbChCETCR8UCrwDDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.srv.ualberta.ca ([129.128.5.19]:54042 "EHLO
	mail2.srv.ualberta.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751718Ab1K3FPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 00:15:12 -0500
In-Reply-To: <CAL1RGDWzVRc4jFtsKUC6FGrdAWn3_OThXpbChCETCR8UCrwDDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Nov 2011, Roland Dreier wrote:
> On Tue, Nov 29, 2011 at 5:17 PM, Marc Aurele La France <tsi@ualberta.ca> wrote:
>> On Tue, 29 Nov 2011, Roland Dreier wrote:
>>> On Tue, Nov 29, 2011 at 1:31 PM, Eric Dumazet <eric.dumazet@gmail.com>
>>> wrote:
>>>> Here is the result of this audit, please double check and test it, I
>>>> only compiled this.

>>> Thanks Eric... I'll queue this up and send it on once we get a good
>>> report from Marc.

>> I can confirm that Eric's patch, retrofitted to 3.1.3, fixes the problem.

> Oh... the problem was already in 3.1?

Yes, but not in anything earlier.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
