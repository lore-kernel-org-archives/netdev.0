From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 12/28] bonding: fill-up LAG changeupper info
 struct and pass it along
Date: Wed, 2 Dec 2015 21:27:50 +0100
Message-ID: <565F5446.4020601@cumulusnetworks.com>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
 <1449086871-19911-13-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38850 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbbLBU1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:27:53 -0500
Received: by wmec201 with SMTP id c201so74605304wme.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:27:52 -0800 (PST)
In-Reply-To: <1449086871-19911-13-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2015 09:07 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Initialize netdev_lag_upper_info structure by TX type according to
> current bonding mode and pass it along via netdev_master_upper_dev_link.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> -added mode broadcast suggested by Nik
> ---
>  drivers/net/bonding/bond_main.c | 45 ++++++++++++++++++++++++++++-------------
>  1 file changed, 31 insertions(+), 14 deletions(-)
> 

LGTM,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
