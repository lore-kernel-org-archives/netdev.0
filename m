From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin Ethernet
Date: Thu, 09 Oct 2014 16:41:48 +0200
Message-ID: <54369EAC.5040301@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com> <20141009163315.2a9e1806@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Antoine_T=E9nart?=
	<antoine.tenart@free-electrons.com>, linux-kernel@vger.kernel.org,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:62016 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbaJIOlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 10:41:53 -0400
In-Reply-To: <20141009163315.2a9e1806@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2014 04:33 PM, Thomas Petazzoni wrote:
> Dear Sebastian Hesselbarth,
>
> On Thu,  9 Oct 2014 14:38:58 +0200, Sebastian Hesselbarth wrote:
>
>> This patch series deals with a removing a IP feature that can be found
>> on all currently supported Marvell Ethernet IP (pxa168_eth, mv643xx_eth,
>> mvneta). The MAC IP allows to automatically perform PHY auto-negotiation
>> without software interaction.
>>
>> However, this feature (a) fundamentally clashes with the way libphy works
>> and (b) is unable to deal with quirky PHYs that require special treatment.
>> In this series, pxa168_eth driver is rewritten to completely disable that
>> feature and properly deal with libphy provided PHYs. The other two drivers
>> are suspect to future patch sets, also removing the code related with it.
>
> Hum, in mvneta, we already disabled the automatic negotiation and use
> libphy. What makes you think the current mvneta driver is wrong in this
> respect?

I didn't check mvneta, but remember Ezequiel didn't clear all AN bits
in the barebox driver (which is based on Linux mvneta). Just mentioned
that I'll have a closer look at it.

But I agree, regarding libphy support mvneta is probably the best
already.

Sebastian
