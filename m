From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/8 V2] [PATCH 5/7: rtlwifi: Fix smatch warning in pci.c
Date: Mon, 16 Sep 2013 23:11:28 +0400
Message-ID: <523757E0.6010903@cogentembedded.com>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net> <1379357722-17687-6-git-send-email-Larry.Finger@lwfinger.net> <5237562D.4080509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:51692 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab3IPTLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 15:11:31 -0400
Received: by mail-la0-f42.google.com with SMTP id ep20so3625089lab.1
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 12:11:29 -0700 (PDT)
In-Reply-To: <5237562D.4080509@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2013 11:04 PM, Sergei Shtylyov wrote:

>> Smatch reports the following:
>>    CHECK   drivers/net/wireless/rtlwifi/pci.c
>> drivers/net/wireless/rtlwifi/pci.c:739 _rtl_pci_rx_interrupt() warn:
>> assigning (-98) to unsigned variable 'stats.noise'

>> This variable is not used and is removed.

>     It is not a variable but a structure field initializer you're removing.

    Meant to also write that your subject is spoiled but forgot. :-)

WBR, Sergei
