From: Alexander Huemer <alexander.huemer-CeK7gDkSoXheoWH0uzbU5w@public.gmane.org>
Subject: Re: [Bug #12261] kernel panics with net_rx_action on kernels above
 2.6.26
Date: Tue, 23 Dec 2008 00:29:26 +0100
Message-ID: <495022D6.3050703@sbg.ac.at>
References: <_EB9bLpq_z.A.hAC.NkYTJB@chimera> <CMMRhk39O-L.A.tMC.TkYTJB@chimera> <20081222072614.GB2631@ff.dom.local> <200812222126.41727.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200812222126.41727.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Monday, 22 of December 2008, Jarek Poplawski wrote:
>   
>> On Sat, Dec 20, 2008 at 11:16:15PM +0100, Rafael J. Wysocki wrote:
>>     
>>> This message has been generated automatically as a part of a report
>>> of regressions introduced between 2.6.26 and 2.6.27.
>>>
>>> The following bug entry is on the current list of known regressions
>>> introduced between 2.6.26 and 2.6.27.  Please verify if it still should
>>> be listed and let me know (either way).
>>>
>>>
>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12261
>>> Subject		: kernel panics with net_rx_action on kernels above 2.6.26
>>> Submitter	: Alexander Huemer <alexander.huemer-CeK7gDkSoXheoWH0uzbU5w@public.gmane.org>
>>> Date		: 2008-12-13 18:43 (8 days old)
>>> References	: http://marc.info/?l=linux-kernel&m=122919424932016&w=4
>>> Handled-By	: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> Patch		: http://marc.info/?l=linux-net&m=122934825227768&w=4
>>>
>>>
>>>       
>> It's fixed in the mainline:
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9a3de25544dadab1971847f28f33b1cd0d1770a6
>>
>> But stables need this too:
>> - 2.6.27 - always
>> - 2.6.26, 2.6.25 (...?) for CONFIG_ADAPTEC_STARFIRE_NAPI
>>     
>
> Thanks, I've just pushed inclusion request to -stable.
>
> Rafael
>   
thanks you for your help, guys.
the problem id definitely fixed with this patch.

-- 
kind regards
alex
