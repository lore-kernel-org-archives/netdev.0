From: Jeremy Brookman <jeremy.brookman@gmail.com>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Wed, 22 Aug 2012 13:06:45 +0100
Message-ID: <CAPc2XZAWnTHaMiXjD-ucg4eLh89Yim439_QjqePxrFSinZhKrw@mail.gmail.com>
References: <4FF27CA0.7030708@8192.net>
	<20120702.221425.418792617776598841.davem@davemloft.net>
	<4FF2853D.9070707@8192.net>
	<20120702.224351.1587084404665143719.davem@davemloft.net>
	<CAPc2XZDHBPKEM+WsWTL+9N_sfgVhOZAoiY3LU=v-QTCb9eQObQ@mail.gmail.com>
	<11100.1345576795@death.nxdomain>
	<503409DC.5010001@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: John Eaglesham <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64107 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab2HVMGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 08:06:46 -0400
Received: by obbuo13 with SMTP id uo13so1306931obb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 05:06:45 -0700 (PDT)
In-Reply-To: <503409DC.5010001@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>         If John signs off and somebody tests this, I'll post a formal
>> submssion with the full commit message.
>
> Since my last submission I ended up making some changes on my end to
> streamline the logic. I can fold together my patch with yours and test them
> later tonight. If everything looks good I'll post the changes back to the
> list.

Great - thanks for that Jay/John; will look forward to the latest
patch later. I'm actually looking at the 2.6.32 branch so have tested
a backport of Jay's patch (which only took a couple of very minor
modifications); a quick test on an 8-port bond with layer3+4 hashing
looked fine.  (Will hold off until the final patch before doing more
testing.)

Regards,

Jeremy

On Tue, Aug 21, 2012 at 11:21 PM, John Eaglesham <linux@8192.net> wrote:
> On 8/21/2012 12:19 PM, Jay Vosburgh wrote:
>>
>> Jeremy Brookman <jeremy.brookman@gmail.com> wrote:
>>
>>>> You should use a mix of tabs, as necessary, to get things to line up
>>>> how I told you they need to line up.
>>>
>>>
>>> Unless I'm missing something, this change doesn't seem to have made it
>>> through to the kernel tip, but we could really use this bugfix. Is it
>>> in a repository I didn't notice, or not yet through the review?  If
>>> it's not through the review, is any help needed to get it there?
>>
>>
>>         The submitter (John Eaglesham) never posted an updated version
>> that addressed the various comments, nor did his original patch
>> submission include a Signed-off-by.
>>
>>         I went ahead and updated the patch to address the comments; I've
>> only compile tested this.  Are you (Jeremy or John) able to test this to
>> confirm that it will hash ipv6 traffic as expected (I can test it, but
>> it won't be today)?
>>
>>         John, can you post a Signed-off-by for your patch (really, this
>> updated version of your patch)?
>>
