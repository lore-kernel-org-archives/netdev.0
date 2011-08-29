From: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:54:59 -0700
Message-ID: <4E5C0AB3.90401@panasas.com>
References: <cover.1314650069.git.joe@perches.com> <8a6378b3fef105983db001fb720c84b669491439.1314650069.git.joe@perches.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com> <20110829.143751.1153162956919885670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	<bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, <neilb-l3A5Bk7waGM@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110829.143751.1153162956919885670.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/29/2011 02:37 PM, David Miller wrote:
> From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Date: Mon, 29 Aug 2011 14:36:17 -0700
> 
>> Big NACK...
>>
>> By whose standard are those "not useful"?
> 
> By mine, that's for sure.  It's duplicating something that the allocation
> layers are already going to print.

I have a question about that. Are the dprints going to show the stack backtrace?
Otherwise how can I see which exact allocation failed and was not properly handled?

If yes above? then I'm not sure I like it either, because am I'll be getting a full
stack backtrace for every failed allocation?

But I might like it if I try. How do I turn on allocation failures prints?
Can I filter out to print only GFP_KERNEL failures and or other GFP combinations?

Thanks 
Boaz
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
