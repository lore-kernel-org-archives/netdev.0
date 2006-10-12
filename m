From: jamal <hadi@cyberus.ca>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 18:12:11 -0400
Message-ID: <1160691131.5047.52.camel@jzny2>
References: <000101c6edd5$a880d430$1a04010a@V505CP>
	 <452E69B2.4030306@hp.com>
	 <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:54451 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751178AbWJLWMP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 18:12:15 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GY8mp-0001UY-Oq
	for netdev@vger.kernel.org; Thu, 12 Oct 2006 18:12:19 -0400
To: Caitlin Bestler <caitlin.bestler@gmail.com>
In-Reply-To: <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-10 at 14:58 -0700, Caitlin Bestler wrote:

> That would seem to limit the usefullness to scenarios where a given
> remote IP address *might* be accepted based on total traffic load,
> number of other connections from the same IP address, etc.  If
> *all* requests from that IP address are going to be rejected, why
> not use netfilter?

Netfilter or ingress tc may both work; 
I have a feeling that the poster needs to consult some policy+state in
the application first which is more complex than what rate control or
number of connections provide (DOS detection?)- in which case, theyd
have to write a netfilter target.

cheers,
jamal


