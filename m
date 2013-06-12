From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: sh_eth: fix incorrect RX length error if
 R8A7740
Date: Thu, 13 Jun 2013 00:03:50 +0400
Message-ID: <51B8D426.3060006@cogentembedded.com>
References: <51B7CFFB.7090801@renesas.com> <51B88271.1030101@cogentembedded.com> <51B8C84A.7000708@cogentembedded.com> <20130612.125552.1263337397196293337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshihiro.shimoda.uh@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:47256 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763Ab3FLUD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 16:03:57 -0400
Received: by mail-la0-f43.google.com with SMTP id gw10so8228508lab.2
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 13:03:55 -0700 (PDT)
In-Reply-To: <20130612.125552.1263337397196293337.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 11:55 PM, David Miller wrote:

>>>> This patch fixes an issue that the driver increments the "RX length
>>>> error"
>>>> on every buffer in sh_eth_rx() if the R8A7740.
>>>> This patch also adds a description about the Receive Frame Status
>>>> bits.

>>>       Thank you.

>>>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>>>> ---
>>>>    This patch is based on the latest net-next.git.

>>>      Since this is a fix, it should have been done against 'net.git'.

>>     David, this patch applies to the recent net.git repo with offset.
>> Could you merge it there and also queue for stable?

> Repost it so that I can apply it cleanly.

    OK, I'll first wait for Shimoda-san's repost as it needs a little 
comment fix anyway.

WBR, Sergei
