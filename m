From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Wed, 16 Nov 2016 18:42:10 +0200
Message-ID: <20161116164210.xkstpgi7uwoxikld@splinter.mtl.com>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
 <1479305343-13167-7-git-send-email-jiri@resnulli.us>
 <e795e6e0-a680-a2c3-7d5e-afd966104a4a@stressinduktion.org>
 <20161116.112735.19078311822311561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, jiri@resnulli.us,
        netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60086 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752875AbcKPQmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:42:13 -0500
Content-Disposition: inline
In-Reply-To: <20161116.112735.19078311822311561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Wed, Nov 16, 2016 at 11:27:35AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 16 Nov 2016 15:51:01 +0100
> 
> > I don't see a way around doing a journal like in filesystems somehow,
> 
> We really just need a sequence counter incremented for each insert/remove,
> and restart the dump from the beginning if it changes mid-dump.

When you dump the FIB table your listener is already registered to the
chain, so any changes happening mid-dump will be propagated to it. I've
noted this in 5/8 and in my reply to Hannes.
