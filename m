From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 4/4] staging: r8192ee: Turn on build of the new driver
Date: Mon, 26 May 2014 13:24:40 -0500
Message-ID: <538386E8.9090105@lwfinger.net>
References: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>	 <1400707536-3338-5-git-send-email-Larry.Finger@lwfinger.net> <1401127560.17377.137.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, zhangfp1@lenovo.com,
	troy_tan@realsil.com.cn
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:43940 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbaEZSYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 14:24:43 -0400
Received: by mail-ob0-f170.google.com with SMTP id uy5so8387499obc.29
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 11:24:42 -0700 (PDT)
In-Reply-To: <1401127560.17377.137.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2014 01:06 PM, Ben Hutchings wrote:
> On Wed, 2014-05-21 at 16:25 -0500, Larry Finger wrote:
> [...]
>> --- /dev/null
>> +++ b/drivers/staging/rtl8192ee/Kconfig
>> @@ -0,0 +1,8 @@
>> +config R8192EE
>> +	tristate "Realtek RTL8192EE Wireless Network Adapter"
>
> depends on MAC80211 && PCI
> (at least)

That should be all that is required.

I'll prepare and send a patch.

Larry
