From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next tree
Date: Thu, 24 Mar 2016 01:04:19 +0200
Message-ID: <CAJ3xEMgth+KpQdcGi3Y8s9_0GJrEESCiEU_8uFGWrMOLHwOdHA@mail.gmail.com>
References: <20160316115809.61b4478e@canb.auug.org.au>
	<CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
	<56E99960.5000604@redhat.com>
	<CA+55aFyi31eRO6nO1-kz=-kq4XqyyA=VagbsiaO4ZPu1aLmnuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyi31eRO6nO1-kz=-kq4XqyyA=VagbsiaO4ZPu1aLmnuA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 16, 2016 at 7:44 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Mar 16, 2016 at 10:35 AM, Doug Ledford <dledford@redhat.com> wrote:
>> On 3/16/2016 1:18 PM, Linus Torvalds wrote:
>>> On Tue, Mar 15, 2016 at 5:58 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:

>>>> I fixed it up (see below) and can carry the fix as necessary (no action
>>>> is required).

>>> Side note: can you change this wording for your manual merge script?
>>> Last merge window (or was it the one before it?) we had confusion with
>>> people who thought that "no action is required" means "you can just
>>> ignore this entirely".

>> I certainly didn't take it that way regardless of the wording.

> It was Or Gerlitz. You were cc'd, since it was the whole rdma Mellanox
> mess. I quote from that thread:
>
>  "> However, the fact that it got resolved in linux-next is purely
>   > informational. It doesn't "fix" the conflict - it just means that both
>   > sides should have gotten informed about it. That doesn't mean that the
>   > conflict goes away or becomes better.
>
>   That's news to me. When such things happen and caught by Stephen, we
>   are getting an email saying something like
>
>   "Today's linux-next merge of the infiniband tree got a conflict
>   between commit X from net-next tree and commit Y from the infiniband
>   tree. I fixed it up (see below) and can carry the fix as necessary (no
>   action is required)."
>
>   Also asked around a bit and got to learn on Stephen using git rerere,
>   so all (no action needed note + seeing git rerere in action...) that
>   leaded me to think that indeed no action is required from our side,
>   but after reading your email (twice, so far), I realized that this was
>   wrong conclusion."

> So that whole "no action is required" wording very much has caused
> confusion before in the rdma camp.

> Let's fix the wording. I'm indeed hopeful that the rdma camp is now
> keenly aware of the issues, but that doesn't change the fact that the
> wording has been problematic.

>> "[...] The Mellanox people are on my xxit-list until they show that they can
>> actually act like responsible people [...]"

Linus,

As I wrote you in that other thread you were quoting from there,
following to the happenings mentioned there, we took responsibility
and made bunch of corrective actions within Mellanox which got us to a
point where there was only one rdma/netdev-next conflict for the 4.6
merge window.

I know there's history here, and in the 4.5 cycle things were much
worse, but I still wanted to put things in their more precise place,
if you don't mind.

Or.
