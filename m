From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Wed, 26 Aug 2015 11:21:59 -0700
Message-ID: <CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
References: <20150826055215.GA2215@nanopsycho.orion> <20150825.230821.2162893312002303587.davem@davemloft.net>
 <20150826073757.GB2215@nanopsycho.orion> <20150826.104906.9246591425074015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36570 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbbHZSWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:22:19 -0400
Received: by obkg7 with SMTP id g7so178845403obk.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:22:18 -0700 (PDT)
In-Reply-To: <20150826.104906.9246591425074015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 10:49 AM, David Miller <davem@davemloft.net> wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Wed, 26 Aug 2015 09:37:57 +0200
>
>> I don't think that are much more cases like this. Therefore I think that
>> for this cases, debugfs might be a good way to expose debugging stats.
>
> Scott wanted to do similar things in rocker.  DSA guys too.
>
> Every switch device is going to have some kind of hierarchy like
> this, it's not a unique situation.

We've been able to get buy so far without a user-visible device for
the switch.  The switch ports are represented by netdevs, so that's
easy.  How can we create an object for the switch itself, so we can
attach common interfaces for the user to dump switch-level stats or
tables?   Using another netdev doesn't seem right.  Do we need a new
device class for switches, and then create some common tool/interfaces
for switch device class?
