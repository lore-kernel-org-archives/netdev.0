From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 5/5]: act_api: mark some functions	static/remove	unused
 function
Date: Thu, 04 Nov 2004 17:24:24 +0100
Message-ID: <418A57B8.9040205@trash.net>
References: <4189CB70.3060703@trash.net>	 <1099576602.1039.151.camel@jzny.localdomain>  <418A4AA0.8070609@trash.net> <1099583639.1081.30.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099583639.1081.30.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Thu, 2004-11-04 at 10:28, Patrick McHardy wrote:
>
>>Ok, here is the same patch without removing tc_lookup_action_id.
>>It is instead surrounded by #if 0.
>>
>
>
>Why is this function bothering you? ;->
>Why do you need to put the #if 0?
>
Because the compiler will warn about an unused static function.

>>- move the functions from include/net/pkt_act.h to act_generic.c
>>
>
>Some of the larger ones make sense to move. Whats the main reason for
>moving them?
>
I was talking about the larger ones. There are multiple
large inline functions that are used by all(?) actions.

>These two make sense. I need help eyeballing the iptables stuff.
>I commented out some of the refcount attempts; also i think quiet a
>few targets are not friendly in getting accessed by anything other than
>iptables; I was going at some point fix them and send you guys patches.
>Maybe you can help me in this area as well.
>  
>

I can't think of a reason why targets would mind beeing used by ipt,
but I'll look out for problems.

>>Is there already userspace-code for anything besides gact ?
>>I would like to test my changes.
>>
>>    
>>
>
>Stephen is probably stalled somewhere because he hasnt been sucking in
>my updates to iproute2.
>I have the latest and greatest on my test machine at home. But here
>are tc updates for ipt and mirred that i could find on my laptop.
>  
>
Thanks.

>The ipt patch needs iptables libraries and may not work with latest
>iptables (although the one at home will surely work). The problem is 
>some of the iptables functions were updated. It would be nice if i didnt
>have to maintain my own variants in user space.
>  
>
I can't see a way to avoid this currently.

Regards
Patrick
