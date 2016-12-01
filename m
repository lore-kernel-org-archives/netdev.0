From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a dump
 of FIB tables during init
Date: Thu, 1 Dec 2016 22:09:19 +0100
Message-ID: <343eadfa-f872-788d-748c-a195c0c4d03a@stressinduktion.org>
References: <1480500546-2544-12-git-send-email-jiri@resnulli.us>
 <eb7ddecd-d6b4-dfce-5990-9e933227c862@stressinduktion.org>
 <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
 <20161201.150445.558407356269727869.davem@davemloft.net>
 <d70996c1-be4e-136b-6325-1a8c152e44ce@stressinduktion.org>
 <20161201205457.xf5evjphjj6mytkf@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
        netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:53801 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753431AbcLAVSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 16:18:37 -0500
In-Reply-To: <20161201205457.xf5evjphjj6mytkf@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.12.2016 21:54, Ido Schimmel wrote:
> On Thu, Dec 01, 2016 at 09:40:48PM +0100, Hannes Frederic Sowa wrote:
>> On 01.12.2016 21:04, David Miller wrote:
>>>
>>> Hannes and Ido,
>>>
>>> It looks like we are very close to having this in mergable shape, can
>>> you guys work out this final issue and figure out if it really is
>>> a merge stopped or not?
>>
>> Sure, if the fib notification register could be done under protection of
>> the sequence counter I don't see any more problems.
> 
> Did you maybe miss my reply yesterday? Because I was trying to
> understand what "ordering" you're referring to, but didn't receive a
> reply from you.

Oh, strange, I am pretty sure I replied to that. Let me resend it.

>> The sync handler is nice to have and can be done in a later patch series.
> 
> Sync handler?

I was talking about SWITCHDEV_SYNC.

Bye,
Hannes
