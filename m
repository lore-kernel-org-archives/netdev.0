From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 08:06:04 -0700
Message-ID: <CAE4R7bDLseNH6U1J8pf5ZmNy2W7kfugNwYAM2P5obKgu-o39pg@mail.gmail.com>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
	<1428934475-15349-2-git-send-email-jiri@resnulli.us>
	<CAE4R7bBndOxs6Gt6ZV8WxNfmW8_GU=-vE4Wp=bCHsAq_rSa1JA@mail.gmail.com>
	<20150413150120.GF2090@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33704 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932355AbbDMPGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:06:07 -0400
Received: by qkx62 with SMTP id 62so184404221qkx.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:06:06 -0700 (PDT)
In-Reply-To: <20150413150120.GF2090@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 8:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Apr 13, 2015 at 04:48:51PM CEST, sfeldma@gmail.com wrote:
>>On Mon, Apr 13, 2015 at 7:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Turned out that "switchdev" sticks. So just unify all releated terms to
>>> use this prefix.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>
>>NACK.  I'm right in the middle of a large patchset which touches all
>>of these files in all of those places and a rename before mine will
>>create a git merge nightmare.  Please wait to post any rename patches
>>until after my set goes in.
>
> Makes sense to me to rename first so you can add new functions with
> "switchdev_" prefix on top of that.

I am renaming, to swdev_ and all new stuff gets swdev_ prefix.  You're
welcome to change the prefix after my patch set goes in but don't try
to slip it under as it totally messes up my patch stack.
