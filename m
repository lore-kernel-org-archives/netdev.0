From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] be2net: Export tunnel offloads only when a VxLAN
 tunnel is created
Date: Thu, 11 Dec 2014 17:35:38 +0300
Message-ID: <5489ABBA.9080102@cogentembedded.com>
References: <1418205364-28979-1-git-send-email-sathya.perla@emulex.com> <20141210.145338.683039710260795306.davem@davemloft.net> <CF9D1877D81D214CB0CA0669EFAE020C68D24ADD@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33041 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbaLKOfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 09:35:45 -0500
Received: by mail-la0-f54.google.com with SMTP id pv20so4382214lab.13
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 06:35:41 -0800 (PST)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C68D24ADD@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/11/2014 10:24 AM, Sathya Perla wrote:

>>> +	netdev->hw_enc_features |= (NETIF_F_IP_CSUM |
>> NETIF_F_IPV6_CSUM |
>>> +	    NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_UDP_TUNNEL);

>> Please indent this properly:

>> 	netdev->hw_enc_features |= (NETIF_F_IP_CSUM |
>> NETIF_F_IPV6_CSUM |
>> 				    NETIF_F_TSO | NETIF_F_TSO6 |
>> NETIF_F_GSO_UDP_TUNNEL);

> Oops, checkpatch didn't seem to catch this...will fix it up and send out a v2 right away...
> thanks!

    Parens are not needed here as well.

WBR, Sergei
