From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 17:19:32 +0200
Message-ID: <20150413151932.GH2090@nanopsycho.lan>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
 <1428934475-15349-2-git-send-email-jiri@resnulli.us>
 <CAE4R7bBndOxs6Gt6ZV8WxNfmW8_GU=-vE4Wp=bCHsAq_rSa1JA@mail.gmail.com>
 <20150413150120.GF2090@nanopsycho.lan>
 <CAE4R7bDLseNH6U1J8pf5ZmNy2W7kfugNwYAM2P5obKgu-o39pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:35702 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbbDMPTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:19:35 -0400
Received: by wgyo15 with SMTP id o15so85244086wgy.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:19:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDLseNH6U1J8pf5ZmNy2W7kfugNwYAM2P5obKgu-o39pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 13, 2015 at 05:06:04PM CEST, sfeldma@gmail.com wrote:
>On Mon, Apr 13, 2015 at 8:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Apr 13, 2015 at 04:48:51PM CEST, sfeldma@gmail.com wrote:
>>>On Mon, Apr 13, 2015 at 7:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Turned out that "switchdev" sticks. So just unify all releated terms to
>>>> use this prefix.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>
>>>NACK.  I'm right in the middle of a large patchset which touches all
>>>of these files in all of those places and a rename before mine will
>>>create a git merge nightmare.  Please wait to post any rename patches
>>>until after my set goes in.
>>
>> Makes sense to me to rename first so you can add new functions with
>> "switchdev_" prefix on top of that.
>
>I am renaming, to swdev_ and all new stuff gets swdev_ prefix.  You're
>welcome to change the prefix after my patch set goes in but don't try
>to slip it under as it totally messes up my patch stack.

Scott, at least please use "switchdev_" prefix for your new stuff so it
does not have to be renamed right after.
