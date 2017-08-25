From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [Intel-wired-lan] how to submit fixes for i40e/i40evf?
Date: Sat, 26 Aug 2017 00:28:52 +0200
Message-ID: <20170826002852.751d5f07@elisabeth>
References: <20170825225215.35fc6b59@elisabeth>
        <CAKgT0UcLAw0958zJ4o9V9Vyamvd1mBQX1+9GAaZw-hZubMqXnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54620 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933777AbdHYW3A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 18:29:00 -0400
In-Reply-To: <CAKgT0UcLAw0958zJ4o9V9Vyamvd1mBQX1+9GAaZw-hZubMqXnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 15:10:08 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Fri, Aug 25, 2017 at 1:52 PM, Stefano Brivio <sbrivio@redhat.com> wrote:
>
> [...]
>
> > Once patches reach Intel's patchwork, will they need to wait for some
> > kind of periodically scheduled pull request process?  
> 
> Once in the patchwork they go through testing and after they have
> passed testing Jeff will try to push them to Dave.

Ok, the whole part above is clear, thanks a lot for clarifying.

> > I don't know if a process is actually defined at this level of detail,
> > but still I feel it's wrong that an obvious fix for a potential crash is
> > waiting in some sort of limbo for 10 days now. Sure, worse things
> > happen in the world, but I can't understand what this patch is waiting
> > for.  
> 
> Well in the case of your patch it was rejected as it didn't apply to
> Jeff's tree

It actually did when I posted it.

> and conflicted with Jacob Keller's patch. He submitted a v2 on Tuesday
> which has only been applied for a few days. Once it receives a
> "Tested-by:"

Which, if I understood correctly, only comes after some internal testing
process, right?

> it will be ready for submission assuming it passes testing.

Now that patch is again in a v2 pull request for net-next, without the
changes I suggested for the commit message. And the same exact code
changes were around for two weeks. IMHO there's room for improvement,
so to speak.

> I hope that helps to clarify things.

It did to some extent, and thanks again for that.
