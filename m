From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 01/28] net: dev: Check CHANGEUPPER notifier
 return value
Date: Wed, 2 Dec 2015 21:23:58 +0100
Message-ID: <565F535E.3000501@cumulusnetworks.com>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
 <1449086871-19911-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, pjonnala@broadcom.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36626 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbbLBUYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:24:01 -0500
Received: by wmww144 with SMTP id w144so230810017wmw.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:24:00 -0800 (PST)
In-Reply-To: <1449086871-19911-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2015 09:07 PM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> switchdev drivers reflect the newly requested topology to hardware when
> CHANGEUPPER is received, after software links were already formed.
> However, the operation can fail and user will not be notified, as the
> return value of the notifier is not checked.
> 
> Add this check and rollback software links if necessary.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> -new patch
> ---

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
