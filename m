From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6 5/5]: act_api: mark some
	functions	static/remove	unused function
Date: 04 Nov 2004 11:31:54 -0500
Message-ID: <1099585914.1081.53.camel@jzny.localdomain>
References: <4189CB70.3060703@trash.net>
	 <1099576602.1039.151.camel@jzny.localdomain>  <418A4AA0.8070609@trash.net>
	 <1099583639.1081.30.camel@jzny.localdomain>  <418A57B8.9040205@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418A57B8.9040205@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-04 at 11:24, Patrick McHardy wrote:

> >Why is this function bothering you? ;->
> >Why do you need to put the #if 0?
> >
> Because the compiler will warn about an unused static function.
> 

fsck the compiler. Ok, fine if-0 it. I will unif-0 it when i submit code
later on.

> >
> >Some of the larger ones make sense to move. Whats the main reason for
> >moving them?
> >
> I was talking about the larger ones. There are multiple
> large inline functions that are used by all(?) actions.
> 

Sure go ahead.


> 
> I can't think of a reason why targets would mind beeing used by ipt,
> but I'll look out for problems.
> 

Try a few targets; what i found is they were bugs in the targets code.
Typically they wont check for something or other that i pass NULL to
and just directly reference it. This could be both in kernel and user
space.


> >The ipt patch needs iptables libraries and may not work with latest
> >iptables (although the one at home will surely work). The problem is 
> >some of the iptables functions were updated. It would be nice if i didnt
> >have to maintain my own variants in user space.
> >  
>
> I can't see a way to avoid this currently.
> 

I guess nobody has needed it before; take a look at the code i
cutnpasted. See if some of that code could be made common and just
referenced by me (since you guys maintain it).

Thanks a lot for your help Patrick.

cheers,
jamal

PS:- I am gonna disappear for a short while - so responses will have
high latency.
