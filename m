From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Wed, 19 Sep 2007 09:33:52 -0400
Message-ID: <1190208832.4259.6.camel@localhost>
References: <1189959274.4241.30.camel@localhost>
	 <20070916.123158.92582301.davem@davemloft.net>
	 <1189975284.4230.14.camel@localhost>
	 <20070917.190133.79431533.davem@davemloft.net>
	 <1190083728.4237.59.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:52993 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbXISNd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 09:33:57 -0400
Received: by wx-out-0506.google.com with SMTP id h31so154488wxd
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 06:33:55 -0700 (PDT)
In-Reply-To: <1190083728.4237.59.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-17-09 at 22:48 -0400, jamal wrote:

> Nothing much has changed from what it was before.
> The only difference is we let go of the queue lock before grabbing
> the tx lock which never mattered for LLTX. 
> Once we grab the tx lock it is the same logic and so far is working well
> on both tg3 and e1000 (which is LLTX). 
> I will continue to retest with net-2.6.24 once you complete rebasing
> and look around to see if anyone maybe affected.

Ok, this is looking solid with this mornings tree. Tested on a dual core
xeon with e1000 (LLTX) and a dual core opteron with tg3 (non-LLTX).
About 100 million packets from udp full throttle on all 4 cpus; i tried
pulling cables etc while doing this to generate extrenous interupts and
didnt see any issues.

Shall i submit the patch?

cheers,
jamal

 

