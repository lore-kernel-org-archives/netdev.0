From: Peter Moody <pmoody@google.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 19:19:59 -0700
Message-ID: <r3nvbqajovk.fsf@perdido.sfo.corp.google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
	<lrhr02$ncj$1@ger.gmane.org> <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com>
	<lrk4f5$4vo$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Alex Elsayed <eternaleye@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <lrk4f5$4vo$2@ger.gmane.org> (Alex Elsayed's message of "Sat\, 02
	Aug 2014 18\:49\:25 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, Aug 02 2014 at 18:49, Alex Elsayed wrote:

> Well, the simple answer is "define a policy that allows everything except 
> network operations, and denies those" - this is reasonably simple if you use 
> ACL groups because you can set the 'default policy' with acl group 0.

I'm not understanding. I don't want to deny network operations, I just
want to be able to associate the operation with the 'offending' process.

> Yeah, there are flavors of Tomoyo (out-of-tree) that can be stacked, and 
> there's the ongoing effort from Casey Schaufler to enable stacking more 
> generally.

Yeah, Casey was the one who suggested that I re-write this as an LSM. I
think he saw the monitoring that I'm trying to do (as opposed to
standard LSM deny/permit) as a good candidate for stacking.


> CaitSith is rather different, in that rather than having domain be the 
> primary key things operate off of, the action is the central piece. So while 
> Tomoyo's policy syntax is
>
> DOMAIN
>     POLICY ACTION CONDITION
>
> CaitSith's is
>
> ACTION [QUALIFIER]
>     PRIORITY POLICY CONDITION [CONDITION...]

Interesting. It sounds like it's still primary designed to deny/permit
actions (based on some policy) and I'm really just looking to monitor.

 Cheers,
 peter
