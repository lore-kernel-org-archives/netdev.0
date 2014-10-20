From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin Ethernet
Date: Mon, 20 Oct 2014 16:37:51 +0200
Message-ID: <54451E3F.1030700@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com> <20141016095323.GA1061@kwain>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141016095323.GA1061@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.10.2014 11:53, Antoine Tenart wrote:
> On Thu, Oct 09, 2014 at 02:38:58PM +0200, Sebastian Hesselbarth wrote:
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
>>
>> Currently, the patches are based on next-20141009 and will be resent once
>> v3.18-rc1 drops. This is a Request-For-Test on both BG2Q and MMP/gplug as
>
> I tested the series on a BG2Q, it worked well.

Antoine,

Thanks for testing! I assume you have added a phy-connection-type
property to BG2Q's ethernet node?

I doubt there will be any Tested-by from MMP guys anytime soon, so
I'll resend this with the minor remarks to be merged for 3.19.

Sebastian
