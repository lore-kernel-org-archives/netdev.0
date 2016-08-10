From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Wed, 10 Aug 2016 15:00:55 -0700
Message-ID: <20160810220055.GE5019@cork>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
 <57A9DA8D.3010407@huawei.com>
 <20160809180830.GM22974@cork>
 <20160809.120636.2039586307820412288.davem@davemloft.net>
 <20160809211058.GP22974@cork>
 <20075.1470786664@famine>
 <20160810212649.GD5019@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, dingtianhong@huawei.com,
	zyjzyj2000@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36177 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254AbcHJWBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 18:01:04 -0400
Received: by mail-pf0-f176.google.com with SMTP id h186so19676396pfg.3
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 15:01:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160810212649.GD5019@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 02:26:49PM -0700, Jörn Engel wrote:
> 
> Having to set one more parameter is a bit annoying.  It would have to be
> documented in a prominent place and people would still often miss it.
> So I wonder if we can make the interface a little nicer.
> 
> Options:
> - If there are no slaves yet and the first slave added is tun, we trust
>   the users to know what they are doing.  Automatically set
>   bond->params.fail_over_mac = BOND_FOM_KEEPMAC
>   Maybe do a printk to inform the user in case of a mistake.
> - If we get an error and the slave device is tun, do a printk giving the
>   user enough information to find this parameter.
> 
> I'm leaning towards the former, but you probably know a reason why I am
> wrong again.

Patch below is an implementation of the former.  Not sure if something
like this is worth considering.

Jörn
