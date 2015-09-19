From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next RFC 3/6] rocker: switch to local transaction
 phase enum
Date: Sat, 19 Sep 2015 15:25:04 -0400
Message-ID: <20150919192504.GB4907@ketchup>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
 <1442665751-10949-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:46263
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750778AbbISTZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 15:25:09 -0400
Content-Disposition: inline
In-Reply-To: <1442665751-10949-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Sep. Saturday 19 (38) 02:29 PM, Jiri Pirko wrote:
> Since switchdev_trans_ph anum is going to be removed, and rocker code is
> way too complicated in this matter to be converted, just introduce local
> enum for transaction phase. Pass it around in local transaction
> structure.

I missed this typo here: s/anum/enum/.

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I found the renaming trick is a bit hard to follow. I am wondering if
this patch could be used first and drop patch 1/6?

That way, you can first add the rocker_trans structure and set its ph
member to obj->trans in obj_add/attr_set, then the following patch
(currently 2/6) would just assign it to the new trans parameter.

Thanks,
-v
