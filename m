From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Sun, 16 Sep 2007 16:52:19 -0400
Message-ID: <1189975939.4230.19.camel@localhost>
References: <1189959274.4241.30.camel@localhost>
	 <20070916.123158.92582301.davem@davemloft.net>
	 <1189975284.4230.14.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:6342 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbXIPUwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 16:52:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1180936wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 13:52:22 -0700 (PDT)
In-Reply-To: <1189975284.4230.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-16-09 at 16:41 -0400, jamal wrote:

> indeed. 
> Ok, maybe i am thinking too hard with that patch, so help me out:->

Ok, that was probably too much of an explanation. What i should say is
if i grabbed the lock explicitly without disabling irqs it wont be much
different than what is done today and should always work.
No?

cheers,
jamal

