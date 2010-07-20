From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC v2] netfilter: xt_condition: add condition target
Date: Tue, 20 Jul 2010 14:32:06 +0300
Message-ID: <1279625526.16431.22.camel@powerslave>
References: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1007201235250.20447@obet.zrqbmnf.qr>
	 <1279623855.16431.4.camel@powerslave>
	 <alpine.LSU.2.01.1007201308370.526@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007201308370.526@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-20 at 13:11 +0200, ext Jan Engelhardt wrote:
> On Tuesday 2010-07-20 13:04, Luciano Coelho wrote:
> >
> >Yes, I made this patch on top of the one you have sent earlier for
> >upstream inclusion.  There were some comments from Patrick to that one
> >and, as I said in my email yesterday, I'll rebase the target patches
> >once the original one is included upstream.
> 
> The original one won't be - that is, basically you will be making the
> initial upstream submission.

Oh, ok.  I thought you had already submitted it to upstream in Apr 21.
As I understood from that thread, you were going to make the necessary
changes and resubmit:

Jan Engelhardt <jengelh@medozas.de> writes:
> On Thursday 2010-04-22 13:14, Patrick McHardy wrote:
> 
> > This looks better, thanks. A few remaining questions about things
> > I missed previously:
> 
> Will deal with it shortly.

But I never saw a follow up to that email (or at least I couldn't find
it in any archives).  Then a few days ago I asked you if you were going
to resend and you answered:

On Fri, 2010-07-16 at 13:20 +0200, ext Jan Engelhardt wrote:
> On Friday 2010-07-16 13:10, Luciano Coelho wrote:
> >Are you planning to resend this patch with the changes Patrick
> >suggested?
> 
> I can try. 

So I assumed you would resubmit it for upstream inclusion.  I probably
misunderstood something in the way then ;)


> However, you are right; fabricating two patches is a good idea and
> is in fact what I advertise too (xt_TEE discussion about specifying
> oif..) - avoiding a singular huge patch is a best practice.

Sure, I also agree that patches should be small and incremental.
Especially since the xt_condition already exists elsewhere, I think it's
best to get it included upstream as is and then start improving it with
subsequent patches.


> Just be sure to have condition plus its 32-bit upgrade patch merged at
> the same time.

I think the best idea will be to send a patchset with the three patches
at once (original xt_condition, plus the target patch, plus the 32-bit
patch).


> >Do you want me to take a look at Patrick's comments and resubmit the
> >patch you've sent with the changes Patrick asked for?
> 
> Yes. Not obeying His Highness's wishes is a death nail for a module ;-)

Heh! And myself, as a newbie, certainly don't want to do that. ;)


-- 
Cheers,
Luca.

