From: Panadero Pizza <panadero_pizza@yahoo.es>
Subject: Re: Putting for discussion "__qdisc_run" bug - strange application-dependant error
Date: Mon, 11 May 2009 11:33:24 +0000 (GMT)
Message-ID: <315332.14155.qm@web28609.mail.ukl.yahoo.com>
References: <657221.87331.qm@web28608.mail.ukl.yahoo.com> <4A06834A.1040307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web28609.mail.ukl.yahoo.com ([87.248.110.218]:29209 "HELO
	web28609.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757571AbZEKLdY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 07:33:24 -0400
In-Reply-To: <4A06834A.1040307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



De: Jarek Poplawski

> Since you're suggesting the specific patch has broken this for you, could

> you simply write if 2.6.24.4 (or 2.6.24.7 with "NET: Add preemption point
> in qdisc_run" patch reverted) also solves your problem?

I'm now testing the 2.6.24.7 kernel with CONFIG_PREEMPT_NONE.
(If I knew how to easily revert the patch for the __qdisc_run function,
I would like to test it, too) ... 

> Btw., you've admitted the stack could be a problem; did you try to enable
> any kernel debugging for this?

Thanks for the hint! I have found the DEBUG_STACKOVERFLOW option,
which seems reasonable. Using it now, too.

Testing will now take some days, because errors are very seldom - I will
post my results here again.

Cheers,
David


      
