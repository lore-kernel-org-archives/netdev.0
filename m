From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Putting for discussion "__qdisc_run" bug - strange application-dependant
   error
Date: Sun, 10 May 2009 13:54:00 +0200
Message-ID: <4A06C058.6040207@gmail.com>
References: <657221.87331.qm@web28608.mail.ukl.yahoo.com> <4A06834A.1040307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Panadero Pizza <panadero_pizza@yahoo.es>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:32982 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbZEJLz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 07:55:29 -0400
Received: by fxm2 with SMTP id 2so2181206fxm.37
        for <netdev@vger.kernel.org>; Sun, 10 May 2009 04:55:27 -0700 (PDT)
In-Reply-To: <4A06834A.1040307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 05/10/2009 09:33 AM:

> Panadero Pizza wrote, On 05/09/2009 09:55 PM

...

>> I have found that from 2.6.24.x on, the __qdisc_run function has been made preemptible and this feature has been enabled for the realization of the afore-said 2.6.24.7 and 2.6.27.12 kernels

...

> Since you're suggesting the specific patch has broken this for you, could
> you simply write if 2.6.24.4 (or 2.6.24.7 with "NET: Add preemption point
> in qdisc_run" patch reverted) also solves your problem?


Btw., let's make it clear: after this patch the __qdisc_run function hasn't
been made preemptible; it could simply exit before all work is finished and
schedule the rest for later.

Jarek P.
