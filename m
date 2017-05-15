From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Mon, 15 May 2017 09:41:09 +0300
Message-ID: <3f1bdc23-2777-0d2b-5cf0-303fa1435a98@grimberg.me>
References: <20170510072627.12060-1-hch@lst.de>
 <1494514662.2489.1.camel@sandisk.com> <20170514055848.GA23149@lst.de>
 <20170514.115116.499149210596634881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hch-jcswGhMUV9g@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170514.115116.499149210596634881.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

>> this patch has not been superceeded by anything, can you explain why
>> it has been marked as such in patchworks?
>
> I think you're being overbearing by requiring this to be marked BROKEN
> and I would like you to explore other ways with the authors to fix
> whatever perceived problems you think SMC has.

Well, its not one's opinion, its a real problem. To be fair, this
security breach existed in other RDMA based storage protocols for
years in the past, but we cleaned it up completely.

Our assumption is that *if* the user is willingly choosing to expose its
entire physical address space to remote access to get some performance
boost that's fine, but to have the kernel expose it by default, without
even letting the user to control it is plain irresponsible. IMHO we
should *not* repeat the mistakes of the past and set a higher bar for
RDMA protocol implementations.

> You claim that this is somehow "urgent" is false.  You can ask
> distributions to disable SMC or whatever in the short term if it
> reallly, truly, bothers you.

I doubt that is sufficient given that not all implementations
out there rely on distros. I'm afraid one time is too much in
this case.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
