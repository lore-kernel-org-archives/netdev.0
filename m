From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 13/18] switchdev: remove unused NETIF_F_HW_SWITCH_OFFLOAD
Date: Mon, 30 Mar 2015 06:38:21 -0700
Message-ID: <551951CD.1060301@cumulusnetworks.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com> <1427704836-8776-14-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36375 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbbC3NiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 09:38:23 -0400
Received: by pdcp1 with SMTP id p1so84484524pdc.3
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 06:38:22 -0700 (PDT)
In-Reply-To: <1427704836-8776-14-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Flag is no longer needed so remove it.  Using the attr get/set recurse algo
> obsoletes the flag.  Setting the flag on bond/team interface, even when the
> consitient member ports didn't have flag set was confusing.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

The flag was there to avoid the recursive lowerdev walk where possible.
bond will have the flag if any one slave can have it. You don't walk the 
bond if it does not have the flag.
Also, this allows the user to disable the feature from userspace if 
required and move everything to software.
