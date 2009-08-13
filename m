From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Iproute2]: failed replacing internal netem qdisc with pfifo
Date: Thu, 13 Aug 2009 23:56:00 +0200
Message-ID: <4A848BF0.1030505@gmail.com>
References: <2036847082.914731250159200857.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com> <20090813120330.GB7010@ff.dom.local> <4A848663.4020304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Patrick McHardy <kaber@trash.net>
To: Marcela Maslanova <mmaslano@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:34748 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbZHMV4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 17:56:31 -0400
Received: by bwz22 with SMTP id 22so850444bwz.18
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 14:56:32 -0700 (PDT)
In-Reply-To: <4A848663.4020304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 08/13/2009 11:32 PM:

...
> The clasfullness isn't actually a big problem if we skip reordering
> (done by putting packets to the head of the queue) for such external
> qdiscs. Alternatively we could modify netem's tfifo behavior (to pfifo)
> with some option. Any suggestions?


...or something in between like classfulness limited to fifos only?

Jarek P.
