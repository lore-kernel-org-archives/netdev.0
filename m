From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Wed, 26 Aug 2015 07:52:15 +0200
Message-ID: <20150826055215.GA2215@nanopsycho.orion>
References: <1440427547-8539-1-git-send-email-jiri@resnulli.us>
 <1440427547-8539-3-git-send-email-jiri@resnulli.us>
 <20150825.142521.1764936130530564868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37408 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbHZFwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 01:52:18 -0400
Received: by widdq5 with SMTP id dq5so4383178wid.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 22:52:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150825.142521.1764936130530564868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 25, 2015 at 11:25:21PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 24 Aug 2015 16:45:46 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Elad Raz <eladr@mellanox.com>
>
>Enough with this debugfs madness.
>
>Expose this stuff through standard interfaces.
>
>They are simple statistics for crying out loud!

They are simple statistics. But they does not fit into any existing
interface. This is about EMAD packets. They are not per-netdevice, but
per-pcidevice. So I cannot put them into ethtool.

I see no other iface to expose this other than debugfs. Please suggest
some other way, I don't see it :/

Thanks.


>
>I'm not applying this, and I'm really getting irritated about how much
>garbage people put into debugfs when it has _NO_ business being there.

I think that is the primary purpose of this iface, To put arbitrary
debugging garbage there. Am I missing something?


>
>Sorry.
