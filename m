From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: Locking validator output on DCCP
Date: Thu, 22 Jun 2006 16:55:04 +1200
Message-ID: <5640c7e00606212155p167e1f07p8b4740b08ccd607a@mail.gmail.com>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
	 <20060621003413.GA31915@gondor.apana.org.au>
	 <20060621105256.GA21015@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	"DCCP Mailing List" <dccp@vger.kernel.org>,
	"Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:31034 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1030603AbWFVEzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 00:55:05 -0400
Received: by wr-out-0506.google.com with SMTP id 50so325172wri
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 21:55:04 -0700 (PDT)
To: "Ingo Molnar" <mingo@elte.hu>
In-Reply-To: <20060621105256.GA21015@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/06, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> > > Can someone tell me whether I am correct in my thinking or not? If I
> > > am then I will work out how to tell the lock validator not to worry
> > > about it.
> >
> > I agree, this looks bogus.  Ingo, could you please take a look?
>
> sure - Ian, could you try Arjan's fix below?
>
>         Ingo
>
> ------------------------------------------------------------
> Subject: lock validator: annotate vlan "master" device locks
> From: Arjan van de Ven <arjan@linux.intel.com>
>
The fix you sent here was the incorrect one but I did test Arjan's as
per previous e-mail.

Real dumb question time. The lock validator is testing for recursive
lock holding. Given that this is a lock at a different address can we
eliminate all such cases? Or are you trying to detect code here that
keeps on locking same type of lock in case of error and we should
explicitly flag...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
