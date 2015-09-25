From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 00/10] switchdev: transaction item queue
 and cleanup
Date: Thu, 24 Sep 2015 23:00:13 -0700 (PDT)
Message-ID: <20150924.230013.2108843761593380405.davem@davemloft.net>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
	<CAE4R7bDJQ6qpSZoR5iDMdOHrDsHJB4+0oRHwLEpqg4Jc3x1Gcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbIYGAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 02:00:15 -0400
In-Reply-To: <CAE4R7bDJQ6qpSZoR5iDMdOHrDsHJB4+0oRHwLEpqg4Jc3x1Gcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Thu, 24 Sep 2015 20:05:39 -0700

> On Thu, Sep 24, 2015 at 1:02 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Jiri Pirko (10):
>>   switchdev: rename "trans" to "trans_ph".
>>   switchdev: introduce transaction item queue for attr_set and obj_add
>>   switchdev: move transaction phase enum under transaction structure
>>   switchdev: add switchdev_trans_ph_prepare/commit helpers
>>   rocker: push struct switchdev_trans down through rocker code
>>   rocker: use switchdev transaction queue for allocated memory
>>   switchdev: remove "NONE" transaction phase
>>   switchdev: remove "ABORT" transaction phase
>>   dsa: use prepare/commit switchdev transaction helpers
>>   switchdev: reduce transaction phase enum down to a boolean
>>
>>  Documentation/networking/switchdev.txt |  19 ++
>>  drivers/net/ethernet/rocker/rocker.c   | 308 ++++++++++++++-------------------
>>  include/net/switchdev.h                |  40 +++--
>>  net/dsa/slave.c                        |  31 ++--
>>  net/switchdev/switchdev.c              | 125 ++++++++++---
>>  5 files changed, 296 insertions(+), 227 deletions(-)
> 
> Tests pass.  ACK on all.
> 
> Acked-by: Scott Feldman <sfeldma@gmail.com>

Series applied, thanks everyone.

But Jiri, in the future you really have to give me more "meat" in this
00/10 posting.  You have to provide some description of what your
changes are doing at a high level and why.

Thanks.
