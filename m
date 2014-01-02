From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 31/31] staging: r8188eu: Fix smatch error
Date: Thu, 02 Jan 2014 16:19:33 -0600
Message-ID: <52C5E5F5.8030200@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net> <1387755422-11443-32-git-send-email-Larry.Finger@lwfinger.net> <20140102084410.GY28413@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:62265 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaABWTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:19:36 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so14750326pbb.8
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:19:36 -0800 (PST)
In-Reply-To: <20140102084410.GY28413@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2014 02:44 AM, Dan Carpenter wrote:
> On Sun, Dec 22, 2013 at 05:37:02PM -0600, Larry Finger wrote:
>> Smatch shows the following:
>>
>>    CHECK   drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
>> drivers/staging/rtl8188eu/core/rtw_mlme_ext.c:1401 OnAssocReq() error: buffer overflow 'pstapriv->sta_aid' 32 <= 32
>>
>
> This is a false positive in Smatch.  Don't do work arounds for buggy
> tools.
>
> If you have the cross function database built on the latest version of
> Smatch then I think it understands the code correctly and doesn't print
> a warning.

When I analyzed the loop in question, I thought it resulted in a subscript of 
[NUM_STA], but I now see that the largest one is [NUM_STA-1]. I will drop this 
patch in the next round.

Thanks for the info regarding a new version of Smatch. I'll update now.

Larry
