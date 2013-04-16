From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Tue, 16 Apr 2013 23:14:46 +0100
Message-ID: <516DCD56.4090508@mentor.com>
References: <1366107927-3642-1-git-send-email-jim_baxter@mentor.com> <CAOMZO5AJt1aLMheqsR_BEpHeGzOTOgrMdjAQFbAY7RmSdOfPoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:35403 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965429Ab3DPWOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 18:14:50 -0400
In-Reply-To: <CAOMZO5AJt1aLMheqsR_BEpHeGzOTOgrMdjAQFbAY7RmSdOfPoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/04/13 16:36, Fabio Estevam wrote:
> On Tue, Apr 16, 2013 at 7:25 AM, Jim Baxter <jim_baxter@mentor.com> wrote:
>> Enables hardware generatation of IP header and
> 
> generation
> 
> 
>> +/* FEC receive accleration */
> 
> acceleration
> 
> ...
> 
>>  static netdev_tx_t
>>  fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>  {
>> @@ -277,6 +333,9 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>         bufaddr = skb->data;
>>         bdp->cbd_datlen = skb->len;
>>
>> +       /* HW accleration for ICMP TCP UDP checksum */
> 
> acceleration
> 

Thank you, I will correct those.

Jim
