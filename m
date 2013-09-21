From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Sat, 21 Sep 2013 17:36:04 +0200
Message-ID: <523DBCE4.1060903@linux-pingi.de>
References: <523C7464.3070007@suse.cz>	<20130920.121535.1653382964468102292.davem@davemloft.net>	<523C753A.8040401@suse.cz> <20130920.122142.1032350399957506112.davem@davemloft.net> <523C780E.5050201@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	akpm@linux-foundation.org, jeffm@suse.com, netdev@vger.kernel.org,
	isdn4linux@koppen.de, isdn@linux-pingi.de,
	sergei.shtylyov@cogentembedded.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50752 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab3IUPgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 11:36:15 -0400
In-Reply-To: <523C780E.5050201@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

thanks for bringing up this this issue again and sorry for not jumping
in earlier.

Am 20.09.2013 18:30, schrieb Jiri Slaby:
> On 09/20/2013 06:21 PM, David Miller wrote:
>> From: Jiri Slaby <jslaby@suse.cz>
>> Date: Fri, 20 Sep 2013 18:18:02 +0200
>>
>>> Ok, let's leave the hole in there then.
>>
>> Jiri, don't turn this on me.
>>
>> The issue is not whether something needs to be fixed or not, I never
>> said "don't fix this" and therefore I'd like to ask politely that you
>> not make it seem like I have.
>>
>> Rather, I'm saying that the implementation is terrible, sets a bad
>> precendence for fixing similar problems, and therefore not is in
>> a state where we can apply it.

OK, the history of this this patch is, that the somebody came up with
the issue, that with the old device node implementation it was simple to
restrict access to a group via standard unix file access rules to avoid
normal users could use ISDN to sniff the bus or even worst for the owner
make high cost calls.
Then somebody came up with this idea, which did allow a similar level of
protection. I did not like it very much nor I had a better idea, SuSE
security people did want it, so it was implemented. I never tried to
push it.

>>
>> So, I'm not saying "don't fix this", I'm saying "fix it properly."
> 

David, since you mention that here are maybe other drivers with same
issues, do you have an idea about a better interface or maybe a
completely other way which could be used to restrict the access to some
group of users.

> Yeah, I understand your point and agree, that the parameter is ugly as
> hell. But investing any more time in ISDN is not worth it, I think.
> Look, I sent the patch a couple times to the ISDN maintainers and they
> didn't even bother to reply. And I am not familiar with the code and do
> not want to spend more time than putting there a single check, sorry.
> Hence, if there is anybody from the ISDN fellows to take care of that,
> nice. If not, we will just live with this patch locally some more years
> and drop it when the ISDN subsystem is dropped from the kernel, if
> dropped at all.
