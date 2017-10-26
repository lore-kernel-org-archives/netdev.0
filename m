From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for
 TSN parameters
Date: Thu, 26 Oct 2017 09:23:00 -0700
Message-ID: <2df92753-1e4a-0dee-c12f-d170c987086b@intel.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
 <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
 <20171026090308.GD20299@lunn.ch>
 <867d6d43-9df7-4097-db5a-f2049236394f@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "Guedes, Andre" <andre.guedes@intel.com>,
        "Briano, Ivan" <ivan.briano@intel.com>
To: Jose Abreu <Jose.Abreu@synopsys.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <867d6d43-9df7-4097-db5a-f2049236394f@synopsys.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jose,


On 10/26/2017 03:08 AM, Jose Abreu wrote:
> Hi Andrew,
> 
> On 26-10-2017 10:03, Andrew Lunn wrote:
>>> These parameters may also need to change in runtime depending on
>>> the scheduled traffic. Unfortunately, net subsystem does not yet
>>> support TSN so this will have to wait and for now we will use
>>> fixed parameters.
>> Hi Jose
>>
>> what you should do is help Linux get support for TSN. Please take part
>> in this discussion:
>>
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.ozlabs.org_cover_808504_&d=DwIBAg&c=DPL6_X_6JkXFx7AXWqB0tg&r=WHDsc6kcWAl4i96Vm5hJ_19IJiuxx_p_Rzo2g-uHDKw&m=8yzdm5iHyWm9cVsYIYUtQNul5WnLO4nLnIxb3WDu-WU&s=6UJ2YJm5jXq6vTWpNRwRzNEuukPboceO61DQgDIpSj0&e=
>>
>> Test the RFC, make sure the concepts will work for your hardware. Make
>> you hardware work with these RFC patches. Help drive TSN forward. Once
>> the core TSN code lands, then you can post patches for your driver.
> 
> After reading more carefully the RFC I noticed that for now it
> only supports CBS. CBS is already supported by stmmac since:
> "net: stmmac: configuration of CBS in case of a TX AVB queue"
> [1]. My main objective now is to add support for EST and FP
> features in stmmac.
>
> As I am a recent contributor to net subsystem I am afraid my
> expertise won't be of much value for now as far as the RFC goes.
>


Please note that our RFC covered more than CBS. We've only provided
patches for the cbs qdisc so far, but we've shared ideas of another
qdisc we've designed and prototyped for EST and FP: taprio. It was a
quite extensive thread, so I recommend reading it all so you can have
a better picture of how the ideas were received back then [1].

In addition to our RFC, there is also the related discussion about
SO_TXTIME proposed by Richard Cochran [2], which I believe might
also be of interest to you.


> 
> About my patches, what I think would be better now would be to
> drop the configuration by DT and integrate the remaining
> configuration, letting the EST parameters be populated by SoC
> specific wrappers. I will then integrate this with the RFC
> patches once they get in and I also intend to contribute with the
> discussion once a new version is sent.


The CBS qdisc patchset is ready to be merged, and based on previous
feedback should go in anytime now.


> 
> I need also to say that this was fully tested and its working as
> expected so, there is no real setback in integrating this now and
> it will save us time in the future because then we will only need
> to implement the callbacks.


Which is great, sure. I believe the point others are making here is
just that there have been some discussions recently that you should
take part of. The goal is getting the *standard* interfaces into
the kernel so we can then provide device driver implementations
through them.

Thanks,
Jesus

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg186431.html
[2] https://www.mail-archive.com/netdev@vger.kernel.org/msg188385.html


> 
> Best regards,
> Jose Miguel Abreu
> 
> [1]
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/drivers/net/ethernet/stmicro/stmmac?id=19d9187317979cf0c25f67017d2676149abc46b2
> 
>>
>>     Andrew
> 
