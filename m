From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] codel: add forgotten inline to functions in header file
Date: Thu, 11 Feb 2016 15:29:41 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32EA0E809@hasmsx107.ger.corp.intel.com>
References: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
 <1455201038.19473.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32EA0E6FD@hasmsx107.ger.corp.intel.com>
 <1455203555.19473.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 02/11/2016 05:12 PM, Eric Dumazet wrote:
> On Thu, 2016-02-11 at 15:05 +0000, Grumbach, Emmanuel wrote:
>
>
>> Yeah :) codel_should_drop seemed very long indeed... I wanted to use the
>> codel_get_time and associated utils (_before, _after) in iwlwifi.
>> They're better than jiffies... So maybe I can just copy that code to
>> iwlwifi.
>
> You certainly can submit a patch adding the inline, but not on all
> functions present in this file ;)
>
> Thanks !
>

Actually... All I need *has* the inline, but if I include codel.h,
codel_dequeue is defined but not used and you definitely don't want to
inline that one. So I guess the only other option I have is to split
that header file which I don't think is really worth it. So, unless you
object it, I'll just copy the code.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
