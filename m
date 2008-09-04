From: david-gFPdbfVZQbY@public.gmane.org
Subject: Re: [GIT]: Networking
Date: Wed, 3 Sep 2008 17:10:54 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0809031703550.30743@asgard.lang.hm>
References: <20080903.161341.239039051.davem@davemloft.net> <alpine.LFD.1.10.0809031615450.3515@nehalem.linux-foundation.org> <alpine.LFD.1.10.0809031621160.3515@nehalem.linux-foundation.org> <20080903.162603.27086959.davem@davemloft.net>
 <20080904000103.GF5967@tesla>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080904000103.GF5967@tesla>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2008, Luis R. Rodriguez wrote:

> On Wed, Sep 03, 2008 at 04:26:03PM -0700, David Miller wrote:
>> From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>> Date: Wed, 3 Sep 2008 16:24:16 -0700 (PDT)
>>
>>> On Wed, 3 Sep 2008, Linus Torvalds wrote:
>>>>
>>>> What's so hard to understand about this?
>>>
>>> Here's a simple rule of thumb:
>>>  - if it's not on the regression list
>>>  - if it's not a reported security hole
>>>  - if it's not on the reported oopses list
>>> then why are people sending it to me?
>>>
>>> IOW, if it's just another random improvement, and you send it to me
>>> outside of the merge window, then what is the point of the merge window?
>>
>> This is exactly what I've been trying to tell the Intel wireless folks
>> but they refuse to listen.
>
> What I think really happens here IMHO is communication needs to be
> enhanced. I only recently noticed that "regression only" policy for
> 2.6.27 for example. I think some of us were rather surprised by it too.

the policy has been the same for quite a while, it's not new for 2.6.27

>> I just won't take their stuff until they get their act in gear.
>>
>> No problem.
>
> On the other side of the spectrum, and to try to understand this better,
> since ath9k is new we obviously cannot get regressions, this means
> unless we find a security hole in our driver or if we can generate an
> oops with 2.6.27 we cannot send patches for ath9k for 2.6.27?
>
> It seems to make sense to me for purposes of stabalizing the kernel for
> sure, however, on the other hand it does also make 2.6.27 miss out on a
> few possible small fixes which may appear here and there.
>
> What will happen then is distributions will end up using their own
> patches on top of the kernel, or users using something like
> compat-wireless to get more bleeding edge stuff. This is exactly what we
> want to avoid.

no, if it's that bad it can go into the -stable kernel patches. but the 
next release kernel will be out in just a couple of months, so it only 
matters for that short window.

> To avoid it I do think another exception needs to be made for patches:
>
> * Small fixes which make something that was not working, which was
>  supposed to work work

but you can't prove that this patch doesn't break something else (if only 
by altering the timing just enough to expose a race condition somewhere)

> If these type of patches cannot be submitted we will have a stable
> kernel for sure but yet buggy leaving people to opt for alternatives
> for small fixes or driver updates.

but if you are changing the continuously, why should people test anything? 
you're going to change it in unpredictable ways before the release anyway.


it may be valid to tinker with a new driver that didn't exist before, but 
this far into the release cycle even that's highly questionable, and if 
you are asking for something to be included becouse of that you need to 
spell it when submiting the patch (and possibly in the changelog)

David Lang
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
