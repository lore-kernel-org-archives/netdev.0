From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 16:02:05 +0300
Message-ID: <200808051602.08047.denys@visp.net.lb>
References: <20080805110453.GA6541@ff.dom.local> <200808051413.58795.denys@visp.net.lb> <20080805122340.GB6541@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:39430 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325AbYHENC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 09:02:59 -0400
In-Reply-To: <20080805122340.GB6541@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Very interesting. Anyway tbf doesn't use gen estimators, so you could
> test if it makes big difference for you.
I can prepare provide details with graphs to private email and reasons why i 
do that. With TBF i think i cannot use flow classifier, if i am not wrong, i 
must attach classful disciplines. I tried to attach just pfifo - and i fail.

> Actually, gen_kill_estimator was rewritten already, but for some
> reason it wasn't merged. Maybe there isn't so much users with such a
> number of classes or they don't delete them, anyway this subject isn't
> reported often to the list (I remember once). Some workaround could be
> probably deleting individual classes (and filters) to give away a lock
> and soft interrupts for a while), before deleting the root, but I
> didn't test this. BTW, you are using quite long queues (3000), so there
> would be interesting to make them less and check if doesn't add to the
> problem (with retransmits).
>
> Jarek P.
Well i am first :-) Many people prefer buy Cisco and put static shaper on 
their NAS for customer. With iproute2 it is possible to make MUCH better 
feeling of using maximum bandwidth, and at same time not feeling it is 
reached maximum. Since in some applications i have much more than amount of 
flows SFQ can provide (and especially inefficient hashing it uses), i need 
flow classifier and a lot of classes.

Many users on my experience dont know much about kernel maillist, and they 
didn't got used to report about problems. Now i am collecting some feedbacks 
from my friends and trying to reproduce and report here.
