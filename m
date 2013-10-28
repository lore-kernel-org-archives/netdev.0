From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: PROBLEM: GRE forwarding not working with 3.10.x, WCCPv2 and Cisco
 7200 Router showing IP0 bad-hlen 4 in tcpdump
Date: Mon, 28 Oct 2013 10:42:09 -0700
Message-ID: <CALnjE+q=a_ats+fmwOhs=YpetHdTMBFuOnhR2rjR0gqekn0tSA@mail.gmail.com>
References: <1381912513.57737.YahooMailNeo@web172002.mail.ir2.yahoo.com>
	<1381942996.2045.135.camel@edumazet-glaptop.roam.corp.google.com>
	<1382007190.35868.YahooMailNeo@web172006.mail.ir2.yahoo.com>
	<1382017464.2045.149.camel@edumazet-glaptop.roam.corp.google.com>
	<1382096356.63655.YahooMailNeo@web172002.mail.ir2.yahoo.com>
	<CALnjE+pdvpfCTo=bTtSrY29mxc0yZKMj0XSc2gQVhGjbpByhcA@mail.gmail.com>
	<1382955011.46218.YahooMailNeo@web172005.mail.ir2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter Schmitt <peter.schmitt82@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:33592 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756796Ab3J1RmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 13:42:12 -0400
Received: by mail-vc0-f169.google.com with SMTP id hu8so2311108vcb.14
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 10:42:09 -0700 (PDT)
In-Reply-To: <1382955011.46218.YahooMailNeo@web172005.mail.ir2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for testing it. I sent patch for stable kernel.

On Mon, Oct 28, 2013 at 3:10 AM, Peter Schmitt <peter.schmitt82@yahoo.de> wrote:
> Hi Pravin,
>
> I tested this patch and it works fine with 3.10.17! Now I get correct packets from the GRE-device and can surf again using WCCP.
>
> Thank you very much!
>
> Best regards,
> Peter
>
>
>
>
>
>> On Friday, October 25, 2013 5:25 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>> > Hi Peter,
>> I think its easy to fix this case, Can you try attached patch?
>> If it works I will send formal patch for stable.
>>
>> Thanks,
>> Pravin.
>>
>>
>> On Fri, Oct 18, 2013 at 4:39 AM, Peter Schmitt <peter.schmitt82@yahoo.de>
>> wrote:
>>>  Hi,
>>>
>>>
>>>
>>>>  On Thursday, October 17, 2013 3:44 PM, Eric Dumazet
>> <eric.dumazet@gmail.com> wrote:
>>>>  > On Thu, 2013-10-17 at 11:53 +0100, Peter Schmitt wrote:
>>>>>   Hi,
>>>>>
>>>>>
>>>>>   >
>>>>>   > 3.10 is buggy (for ETH_P_WCCP support I mean), 3.11 has the
>> probable
>>>>>   > fix :
>>>>>   >
>>>>>   > commit 3d7b46cd20e300bd6989fb1f43d46f1b9645816e
>>>>>   > ("ip_tunnel: push generic protocol handling to ip_tunnel
>>>>  module.")
>>>>>   >
>>>>>   > The problem is 3.10 do not pull the extra 4 bytes of WCCP
>>>>>   >
>>>>>   > This is now properly done in iptunnel_pull_header()
>>>>>   >
>>>>>
>>>>>   First of all, many thanks for your help on this.
>>>>>
>>>>>   I tried to apply the fix to the 3.10.16 sources, as I would like
>> to
>>>>>   stay with the long-term line. Unfortunately it does not apply, as
>>>>>   there are a lot of dependencies on other patches.
>>>>>
>>>>>   Do you think there will be a fix for the long-time 3.10 kernel
>> line?
>>>>>   Or can you guide me on how to apply this fix to the long-term
>> kernel?
>>>>
>>>>  3.10 is right in the middle of GRE refactoring, and many bugs are in
>> it.
>>>>
>>>>  It might be very painful to get a complete list of patches to backport.
>>>
>>>  thanks again. Yes I saw that there were lots of changes.
>>>
>>>  Do you think there will be a fix for all the 3.10.x stable long term kernel
>> users? Many of them might not be able to use some newer kernel easily or will
>> this be a "won't fix"?
>>>
>>>  Best regards,
>>>  Peter
>>>
>>
