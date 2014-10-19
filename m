From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: qdisc running
Date: Sun, 19 Oct 2014 15:24:42 -0400
Message-ID: <54440FFA.40307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric Dumazet <edumazet@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:63964 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbaJSTYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 15:24:49 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so3543420iec.9
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2014 12:24:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jesper,

You asked at the meeting the point to qdisc running.
Original intent is to allow only one cpu to enter the lower half of the
qdisc path. IOW, if one cpu was already in the qdisc then that guy
could be used to dequeue packets. i.e this is good for batching.
Original idea was Herbert's with major improvement from Eric
and a small one from me.

For history of different tried approaches look at:
Look at slide 2: 
http://vger.kernel.org/netconf2011_slides/jamal_netconf2011.pdf
then download the **amazing** flash animations which describe
that history.
http://vger.kernel.org/netconf2011_slides/netconf-2011-flash.tgz

Follow the bullets in slide2 and map to the flash animations.

If you go over them, you'll see it is still needed.

I think someone oughta put those **amazing** animations on some
website;->

cheers,
jamal
