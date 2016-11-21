From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Mon, 21 Nov 2016 10:59:41 +0530
Message-ID: <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com> <20161119135654.GA14079@lnxartpec.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joao Pinto <Joao.Pinto@synopsys.com>, mued dib <kreptor@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jiri@mellanox.com,
        saeedm@mellanox.com, idosch@mellanox.com,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
        CARLOS.PALMINHA@synopsys.com, andreas.irestal@axis.com,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, lars.persson@axis.com
To: Rabin Vincent <rabin@rab.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161119135654.GA14079@lnxartpec.se.axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 19, 2016 at 7:26 PM, Rabin Vincent <rabin@rab.in> wrote:
> On Fri, Nov 18, 2016 at 02:20:27PM +0000, Joao Pinto wrote:
>> For now we are interesting in improving the synopsys QoS driver under
>> /nect/ethernet/synopsys. For now the driver structure consists of a single file
>> called dwc_eth_qos.c, containing synopsys ethernet qos common ops and platform
>> related stuff.
>>
>> Our strategy would be:
>>
>> a) Implement a platform glue driver (dwc_eth_qos_pltfm.c)
>> b) Implement a pci glue driver (dwc_eth_qos_pci.c)
>> c) Implement a "core driver" (dwc_eth_qos.c) that would only have Ethernet QoS
>> related stuff to be reused by the platform / pci drivers
>> d) Add a set of features to the "core driver" that we have available internally
>
> Note that there are actually two drivers in mainline for this hardware:
>
>  drivers/net/ethernet/synopsis/
>  drivers/net/ethernet/stmicro/stmmac/

Yes the later driver (drivers/net/ethernet/stmicro/stmmac/) supports
both 3.x and 4.x. It has glue layer for pci, platform, core etc,
please refer this driver once before you start.

You can start adding missing feature of 4.x in stmmac driver.

>
> (See http://lists.openwall.net/netdev/2016/02/29/127)
>
> The former only supports 4.x of the hardware.
>
> The later supports 4.x and 3.x and already has a platform glue driver
> with support for several platforms, a PCI glue driver, and a core driver
> with several features not present in the former (for example: TX/RX
> interrupt coalescing, EEE, PTP).
>
> Have you evaluated both drivers?  Why have you decided to work on the
> former rather than the latter?



-- 
wwr
Rayagond
