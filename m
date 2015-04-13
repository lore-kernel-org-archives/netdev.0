From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 13:24:38 -0400 (EDT)
Message-ID: <20150413.132438.259409084264003362.davem@davemloft.net>
References: <20150413150120.GF2090@nanopsycho.lan>
	<CAE4R7bDLseNH6U1J8pf5ZmNy2W7kfugNwYAM2P5obKgu-o39pg@mail.gmail.com>
	<20150413151932.GH2090@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com,
	gospo@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932415AbbDMRYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:24:40 -0400
In-Reply-To: <20150413151932.GH2090@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 13 Apr 2015 17:19:32 +0200

> Mon, Apr 13, 2015 at 05:06:04PM CEST, sfeldma@gmail.com wrote:
>>On Mon, Apr 13, 2015 at 8:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Mon, Apr 13, 2015 at 04:48:51PM CEST, sfeldma@gmail.com wrote:
>>>>On Mon, Apr 13, 2015 at 7:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> Turned out that "switchdev" sticks. So just unify all releated terms to
>>>>> use this prefix.
>>>>>
>>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>>
>>>>NACK.  I'm right in the middle of a large patchset which touches all
>>>>of these files in all of those places and a rename before mine will
>>>>create a git merge nightmare.  Please wait to post any rename patches
>>>>until after my set goes in.
>>>
>>> Makes sense to me to rename first so you can add new functions with
>>> "switchdev_" prefix on top of that.
>>
>>I am renaming, to swdev_ and all new stuff gets swdev_ prefix.  You're
>>welcome to change the prefix after my patch set goes in but don't try
>>to slip it under as it totally messes up my patch stack.
> 
> Scott, at least please use "switchdev_" prefix for your new stuff so it
> does not have to be renamed right after.

Scott, I think Jiri's request is reasonable.
