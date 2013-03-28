From: Fernando Luis Vazquez Cao <fernando_b1-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors
Date: Thu, 28 Mar 2013 14:37:18 +0900
Message-ID: <5153D70E.5070302@lab.ntt.co.jp>
References: <1363675513.4767.6.camel@nexus> <51515E5E.7020309@lab.ntt.co.jp> <20130326104833.GA5331@localhost> <51527239.5070505@lab.ntt.co.jp> <20130327175138.GA5717@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130327175138.GA5717@localhost>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013-03-28 02:51, Pablo Neira Ayuso wrote:
> On Wed, Mar 27, 2013 at 01:14:49PM +0900, Fernando Luis Vazquez Cao wrote:
>>> I'd like to find a possible solution for the EPERM problem that we've
>>> been discussing. It requires some rework and performance evaluation.
>> The problem is that there is a huge installed base of
>> systems that show this broken behaviour, so even if
>> we find a proper fix for it we still should document
>> which systems may be affected by the spurious EPERM
>> bug, thus giving application programmers a chance to
>> add logic to their programs to recover from such
>> eventualities.
> I see. The problem is that it will take some time until that manpage
> update reaches main distributions, by that time we may have fixed it
> already in existing kernels. Then, we'll have to remove it again.

IMHO, if the second patch were applied too and we managed to
fix the bug it documents after that, we should not revert it but
apply a new patch along the lines of: "In older versions of the
Linux kernel (< 3.??) ...". I will certainly want applications
developed on future distributions to work properly on my legacy
Debian Squeeze systems (a distribution upgrade or a backport
of the upstream fix to your distribution's kernel may not possible).


> I still think patch 1 already provides some clue to programmers
> regarding EPERM at this moment (even if not so explicit and detailed).

For the reasons exposed above I'd rather have the second patch
applied too, but I will defer to you and Michael on that regard.


> Please, ping me again if we didn't come up with some solution for this
> in some prudential amount of time.

I will. Thank you. I would appreciate it if you kept me CCed.


- Fernando
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
