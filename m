From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 11:51:44 -0500
Message-ID: <1107190304.1077.101.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <41FE5C57.2020201@pobox.com>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: andre.correa@pobox.com
In-Reply-To: <41FE5C57.2020201@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 11:27, Andre Correa wrote:
> Hi all,
> 
> it turned an year since we (me and some cool folks) got the original IMQ 
> from "death". During this year we updated kernel and iptables patches 
> for every available version, created some new features (like hooking 
> after and before NAT, multiple IMQ devices, solved modules problems, 
> etc), and helped lots of users in our mailling list. The wish list grew, 
> we created a site/FAQ/WiKi. We are still missing "dumb device" 
> functionality. Our site is www.linuximq.net
> 

nice. Since you are deeply involved i think you can help put closure to
this.

> Complicated or not, clean or not, its being working in some interresting 
> scenarios with lots of load on it. I feel fine for being able to help 
> the community somehow with it. Found no time yet to check Jamal's new 
> patches but we would use dummy as the base for "real device" 
> functionality development.
> 
> At least its nice to find we are discussing how to do it, not anymore if 
> IMQ functionality is needed, cause it really is.
> 

The people have spoken i suppose is the right way to describe it.
If a lot of people use it, then its existence is justified. The problem
has been misrepresenation of why its needed.

> Going one way or another we should not let users alone again with nobody 
> taking care of this like it happened before. I plan keeping IMQ updated 
> with new kernel versions as usual.
> 
> Jamal, when you say "to replace" you mean it may get into vanila kernel? 
> Do you plan keeping it updated from now on?
> 

The plan is to make that small update to the kernel to achieve the
funtionality that IMQ provides. It doesnt have to be me who does the
updating thereafter; you can own this for example. The goal is to meet
those requirements with little noise in the kernel. If we have things in
the kernel, then there should be no need to maintain separate patches. 

> Either way, can we call this new thing something else, because actual 
> users may not want to migrate, so both should work together. A user 
> should be able to patch a kernel with both.

I dont have an issue with renaming but i dont see any overwhelming
reason to do it on a new device when dummy seems to be sufficient.
Take a look at that patch and see what functionality is missing.
Forget about the iptable hooks. See the thread of discussion
to see how the plan to meet those requirements looks like - see if
something is missing. Please read the text i posted - it is verbose but
would give a good explanation.

> We (at linuximq.net) would be more then happy to help with it.

Like i said you guys can own this - just wanna reduce cruft in the
kernel.

cheers,
jamal
