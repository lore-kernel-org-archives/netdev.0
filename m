From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 21:19:38 +0200
Message-ID: <20150413191938.GB2058@nanopsycho.orion>
References: <20150413150120.GF2090@nanopsycho.lan>
 <CAE4R7bDLseNH6U1J8pf5ZmNy2W7kfugNwYAM2P5obKgu-o39pg@mail.gmail.com>
 <20150413151932.GH2090@nanopsycho.lan>
 <20150413.132438.259409084264003362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com,
	gospo@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38507 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbbDMTTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 15:19:41 -0400
Received: by wiun10 with SMTP id n10so78790896wiu.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 12:19:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150413.132438.259409084264003362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 13, 2015 at 07:24:38PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 13 Apr 2015 17:19:32 +0200
>
>> Mon, Apr 13, 2015 at 05:06:04PM CEST, sfeldma@gmail.com wrote:
>>>On Mon, Apr 13, 2015 at 8:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Mon, Apr 13, 2015 at 04:48:51PM CEST, sfeldma@gmail.com wrote:
>>>>>On Mon, Apr 13, 2015 at 7:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>> Turned out that "switchdev" sticks. So just unify all releated terms to
>>>>>> use this prefix.
>>>>>>
>>>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>>>
>>>>>NACK.  I'm right in the middle of a large patchset which touches all
>>>>>of these files in all of those places and a rename before mine will
>>>>>create a git merge nightmare.  Please wait to post any rename patches
>>>>>until after my set goes in.
>>>>
>>>> Makes sense to me to rename first so you can add new functions with
>>>> "switchdev_" prefix on top of that.
>>>
>>>I am renaming, to swdev_ and all new stuff gets swdev_ prefix.  You're
>>>welcome to change the prefix after my patch set goes in but don't try
>>>to slip it under as it totally messes up my patch stack.
>> 
>> Scott, at least please use "switchdev_" prefix for your new stuff so it
>> does not have to be renamed right after.
>
>Scott, I think Jiri's request is reasonable.

Dave, I think you can go ahead and apply this patchset. I'll help Scott
with rebasing this patchset on top of this.

Thanks.
