From: "Tantilov, Emil S" <emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [Bug #14252] WARNING: at include/linux/skbuff.h:1382 w/ e1000
Date: Mon, 23 Nov 2009 11:02:43 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA6A95F33@rrsmsx501.amr.corp.intel.com>
References: <ipicVA1QUFF.A.zWB.1mdALB@chimera>
	<OWmO9uyC1hM.A.w9C.NodALB@chimera>
 <20091119.120721.252464351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org" <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "rjw-KKrjLPT3xs0@public.gmane.org" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091119.120721.252464351.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
> Date: Tue, 17 Nov 2009 00:01:18 +0100 (CET)
> 
>> This message has been generated automatically as a part of a report
>> of regressions introduced between 2.6.30 and 2.6.31.
>> 
>> The following bug entry is on the current list of known regressions
>> introduced between 2.6.30 and 2.6.31.  Please verify if it still
>> should be listed and let me know (either way).
>> 
>> 
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14252
>> Subject		: WARNING: at include/linux/skbuff.h:1382 w/ e1000
>> Submitter	: Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>
>> Date		: 2009-09-20 11:26 (58 days old)
>> References	: http://marc.info/?l=linux-kernel&m=125344599006033&w=4
> 
> Please CC: netdev when reporting networking problems, thank you.
> 
> Intel folks can you please take a look at this?  Thanks.

I have not been able to reproduce this issue so far. I don't have the exact same HW, but I tested on stock 2.6.31 with 82541 based NIC. More than 3 days now of stress without a problem.

If the reporter can provide some additional information that may be of help:
1. cat /proc/interrupts
2. ethtool -i ethX (where ethX is the interface that is causing the problem
3. lspci -vvv
4. ethtool -e ethX
5. specific settings that may deviate from the default configuration (like MTU)
6. type of traffic that is causing the issue.

Thanks,
Emil--
To unsubscribe from this list: send the line "unsubscribe kernel-testers" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
