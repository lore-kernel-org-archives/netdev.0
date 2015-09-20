From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 3/6] rocker: switch to local transaction
 phase enum
Date: Sun, 20 Sep 2015 10:59:20 +0200
Message-ID: <20150920085920.GC2203@nanopsycho.orion>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
 <1442665751-10949-4-git-send-email-jiri@resnulli.us>
 <20150919192504.GB4907@ketchup>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37877 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbbITI7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 04:59:23 -0400
Received: by wicfx3 with SMTP id fx3so75791516wic.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 01:59:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150919192504.GB4907@ketchup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 19, 2015 at 09:25:04PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Hi Jiri,
>
>On Sep. Saturday 19 (38) 02:29 PM, Jiri Pirko wrote:
>> Since switchdev_trans_ph anum is going to be removed, and rocker code is
>> way too complicated in this matter to be converted, just introduce local
>> enum for transaction phase. Pass it around in local transaction
>> structure.
>
>I missed this typo here: s/anum/enum/.
>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>I found the renaming trick is a bit hard to follow. I am wondering if
>this patch could be used first and drop patch 1/6?
>
>That way, you can first add the rocker_trans structure and set its ph
>member to obj->trans in obj_add/attr_set, then the following patch
>(currently 2/6) would just assign it to the new trans parameter.

That could work locally for rocker, but for the rest of the code, I
belive it would not. Anyway, the result would be the same.
