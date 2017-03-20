From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next] stmmac: call stmmac_init_phy from
 stmmac_dvr_probe
Date: Mon, 20 Mar 2017 17:46:01 +0000
Message-ID: <ea079bf2-70e3-e584-4218-75e33ac558a5@synopsys.com>
References: <20170320172915.8313-1-niklass@axis.com>
 <ca027cda-2a8f-55d9-42e9-7f26e832e7bf@synopsys.com>
 <5921fa33-5509-a158-80d6-acda7e68b418@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5921fa33-5509-a158-80d6-acda7e68b418@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 5:44 PM de 3/20/2017, Niklas Cassel escreveu:
> On 03/20/2017 06:42 PM, Joao Pinto wrote:
>> Às 5:29 PM de 3/20/2017, Niklas Cassel escreveu:
>>> From: Niklas Cassel <niklas.cassel@axis.com>
>>>
>>> It is usually possible to do
>>> ethtool -s autoneg on
>>> so that you trigger an autoneg before calling
>>> ip link set dev eth0 up
>>>
>>> However, stmmac returns -EBUSY if !netif_running.
>>> The only reason for this appears to be that stmmac_init_phy
>>> is called from stmmac_open instead of from stmmac_dvr_probe.
>>>
>>> Move stmmac_init_phy to stmmac_dvr_probe so that ethool
>>> works as soon as register_netdev has been called.
>>> stmmac_check_ether_addr was also moved to probe,
>>> so that the ordering doesn't change.
>>>
>>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
>>> ---
>> Hi Niklas, did you test this patch?
> 
> I tested it on our hardware, but it would be nice
> if you could test it on your side, since you are
> using the PCI glue layer.
> 

Ok, I can do that. As Florian stated in a past e-mail, this change might not be
compatible with all setups.

Joao
