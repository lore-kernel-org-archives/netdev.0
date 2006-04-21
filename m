From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 16:46:51 -0400
Message-ID: <bdfc5d6e0604211346n50b15f56g4ebc2fe5fe88a63a@mail.gmail.com>
References: <1145578214.3195.6.camel@rh4>
	 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
	 <20060421024024.GA29644@gondor.apana.org.au>
	 <1145582676.3195.18.camel@rh4>
	 <20060421132758.GA26161@gospo.rdu.redhat.com>
	 <1145633287.3194.10.camel@rh4>
	 <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>
	 <1145646031.3843.5.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, shawvrana@gmail.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.194]:62733 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932434AbWDUUqv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:46:51 -0400
Received: by nz-out-0102.google.com with SMTP id 40so488864nzk
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2006 13:46:51 -0700 (PDT)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1145646031.3843.5.camel@rh4>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/21/06, Michael Chan <mchan@broadcom.com> wrote:
> On Fri, 2006-04-21 at 16:01 -0400, Andy Gospodarek wrote:
>
> > I just hate to see extra resources used to solve problems that good
> > coding can solve (not that my suggestion is necessarily a 'good' one),
> > so I was trying to think of a way to resolve this without explicitly
> > adding another workqueue.
>
> If you don't want to add another workqueue, then look at tg3, bnx2, and
> one of the smc drivers on how to effectively wait for the driver's
> workqueue task to finish without deadlocking with linkwatch_event.
>

I agree 100%.  I just hope others can manage to figure that out too.
