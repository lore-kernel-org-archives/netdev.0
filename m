From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 14:04:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824120442.GA21296@postel.suug.ch>
References: <20040824094952.GF21073@postel.suug.ch> <E1BzYMJ-000208-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1BzYMJ-000208-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1BzYMJ-000208-00@gondolin.me.apana.org.au> 2004-08-24 20:16
> Please think about the meaning of the value.  Is anyone going to have a queue
> bigger than 2^32?
> 
> And if the answer is yes, then please use u64.

Can you please explain the actual reason for using a fixed width
type when all existing numeric attributes use arch depedent types?

I agree with you, if it happens to be the reason, that it is easier for a
userspace application to use fixed width types but we should change
it for all attributes if the decision is made for this one.

I have more patches in my queue which would throw up the same question
again. Therefore I'd like to see it discussed now and a decision to be
made whether to use fixed width types or not.

   Thomas
