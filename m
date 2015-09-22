From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/10] switchdev: transaction item queue and
 cleanup
Date: Tue, 22 Sep 2015 18:53:48 +0200
Message-ID: <20150922165348.GD2253@nanopsycho.orion>
References: <1442930031-4732-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAVGGKQsGu5MyWMvZQCcH_FkxGT96ivHj9RArsua4N32Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37605 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758072AbbIVQxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:53:51 -0400
Received: by wicfx3 with SMTP id fx3so33402935wic.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 09:53:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAVGGKQsGu5MyWMvZQCcH_FkxGT96ivHj9RArsua4N32Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 22, 2015 at 06:22:23PM CEST, sfeldma@gmail.com wrote:
>On Tue, Sep 22, 2015 at 6:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
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
>>  drivers/net/ethernet/rocker/rocker.c | 311 +++++++++++++++--------------------
>>  include/net/switchdev.h              |  40 +++--
>>  net/dsa/slave.c                      |  31 ++--
>>  net/switchdev/switchdev.c            |  99 ++++++++---
>>  4 files changed, 252 insertions(+), 229 deletions(-)
>
>I like this version much better!  Thank you for making the
>adjustments.  My main concern about easily opting-out of prepare phase
>is gone.  And I appreciate that you moved trans * as arg to attr_set
>and obj_add.
>
>Would you add a write-up in switchdev.txt about prepare-commit model
>and how to use the transaction object?  Add it to this patchset, if
>you can.

Okay.

>
>What testing have you done?  I'll do testing today on my bench and
>report back, but I kind of want to know what to expect.

I did basic smoke tests with bridged rocker ports.

>
>Give a day or two for testing and review.

Thanks!
