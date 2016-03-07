From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl
 adjustments
Date: Mon, 7 Mar 2016 06:21:17 -0500
Message-ID: <56DD642D.8010401@mojatatu.com>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
 <499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
 <20160302095414.45a928df@xeon-e3> <56D84863.5090203@mojatatu.com>
 <20160303143229.GC18624@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:33878 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcCGLVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 06:21:25 -0500
Received: by mail-ig0-f195.google.com with SMTP id vs8so2385978igb.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 03:21:24 -0800 (PST)
In-Reply-To: <20160303143229.GC18624@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-03 09:32 AM, Phil Sutter wrote:
> Hi,
>

>
>> The patches look good to me. Phil, maybe get rid of that comment at the
>> top which was worrying about endianness. I think you fixed it.
>
> I'm not so sure. The kernel explicitly takes care to get the bit
> ordering right:
>
[..]
> act_pedit though just mangles the whole byte as-is, and if that was
> correct, we would not have to go that extra mile in struct iphdr, or do
> we?
>

I meant in general - the note to say that there are endianes issues
should go.


>> These would of course require more of a larger setup to vet
>> and running tcpdump to check the correct bytes are being
>> modified.
>

Indeed - That is how i normally would test. It is more complex.
Your scheme is good - but will not catch a kernel bug.

> Since I am lazy, I wanted to have as much automation as possible while
> testing. Therefore I just assumed that act_pedit does the right thing
> all the time,

famous last words ;->

> and iproute just has to feed it correct values. Given the
> scope of this patch, this is also completely sufficient. Of course, the
> tests/ directory would benefit more from a full test. But since
> automation then becomes tricky, I'm not sure it makes much sense to
> deliberately write code for that.
>

Your test is still useful and i think should go into the tests dir.

cheers,
jamal

> Thanks for the review,
>
> Phil
>
