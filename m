From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 18:43:24 +0100
Message-ID: <20111229174323.GC2948@hell>
References: <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
 <1324664907.2915.5.camel@edumazet-laptop>
 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
 <1324668083.2915.15.camel@edumazet-laptop>
 <1325132760.2607.15.camel@edumazet-laptop>
 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
 <1325149922.2607.33.camel@edumazet-laptop>
 <20111229165249.GB2948@hell>
 <1325178950.2607.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:53510 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754541Ab1L2Rn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 12:43:26 -0500
Content-Disposition: inline
In-Reply-To: <1325178950.2607.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-12-29 18:15:50 [+0100]:

>> In other words netem jitter and a qdisc !tfifo will not work. Correct? The
>> rate extension also peak the last packet to get the reference time (assuming a
>> strict ordering):
>> 
>
>Yep, current situation is borked. It assumes we _use_ tfifo, for delay
>jitters but also for rate extension.

Mhh, should we signal this to the user via 'tc -s qdisc show'? Or should we
assume that a user who set netem rate|jitter AND a qdisc !tfifo knows what he
does - because we assume he is a experienced user? At least somewhere in the
manpage a comment should point to this characteristic.
