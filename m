From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Thu, 02 Oct 2014 08:53:11 -0400
Message-ID: <542D4AB7.7070507@mojatatu.com>
References: <20140930085114.24043.81310.stgit@dragon>	<542A8EF9.10403@mojatatu.com>	<20140930.142038.235338672810639160.davem@davemloft.net>	<542BFEF3.7020302@mojatatu.com>	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>	<542C1F1F.90404@mojatatu.com>	<20141001192840.5679a671@redhat.com>	<542C4E0D.4050404@mojatatu.com>	<20141001214700.18b16387@redhat.com>	<542C5E8B.7070204@mojatatu.com> <20141001223229.6cbaac07@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?windows-1252?Q?Toke_H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:47759 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbaJBMxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 08:53:19 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so1484386ier.20
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 05:53:19 -0700 (PDT)
In-Reply-To: <20141001223229.6cbaac07@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/14 16:32, Jesper Dangaard Brouer wrote:
> On Wed, 01 Oct 2014 16:05:31 -0400

> I'll try to make it more explicit.
> Will resubmit patchset shortly...
>

Thanks for providing the clarity.

> Notice it is not difficult cause a queue to form, but it is tricky (not
> difficult) to correctly test this patchset.  Perhaps you misread my
> statement earlier as "it was difficult to test and cause a queue to form"?
>

The conflict maybe what "difficult" or "common" means.
I know from experience that it is difficult under *normal*
circumstances to create the overload. Example you had to turn
off GSO/TSO to see it for 10G ;-> iow you had to go out of your way to
turn off a useful feature. So you are no longer dealing with "common".
Which is fine by me - I just wanted you to specify that was the
case. I also wanted you to run the testcase which said "this is
how things were before my patch" for 10G (with GSO/TSO). But i
dont think you are in the mood for that and if your patch goes
in, then the reaction to any regression to that wouldnt take long.
If something breaks people would start whining in a short period.
So I am ok with it.


> I think you could read this blog in 30 sec:
>   http://netoptimizer.blogspot.dk/2014/04/basic-tuning-for-network-overload.html
>

Ok, yes that message was clear in 30 seconds or less ;-> Immediate
gratification.
It is what i would do (havent tried tweaking c states) - but off the
bat, I would do what you did when i want to run serious networking.

> My cover letter and testing section... will take you longer that 30
> sec, it have grown quite large (and Eric will not even read it :-P ;-))
>

But it is referenced forever - so i can go back and read it. A url
may return a 404 in 5 years.

> Believe or not, I've actually restricted and reduced the testing
> section.

I agree there is an upper bound to how much testing you can do.
Looking forward to seeing a paper with all the nice details.

cheers,
jamal
