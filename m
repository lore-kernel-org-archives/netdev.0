From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Fri, 18 Nov 2016 14:20:27 +0000
Message-ID: <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
        <jiri@mellanox.com>, <saeedm@mellanox.com>, <idosch@mellanox.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <andreas.irestal@axis.com>
To: mued dib <kreptor@gmail.com>, Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ozgur,

Thanks for your feedback.

On 18-11-2016 13:09, mued dib wrote:
> Dear Joao;
> 
> thanks for support and this project is good. I have some questions, Linux
> already support to QoS with "tc". right?
> 
> Can you send us a list of driver files you are interested?

For now we are interesting in improving the synopsys QoS driver under
/nect/ethernet/synopsys. For now the driver structure consists of a single file
called dwc_eth_qos.c, containing synopsys ethernet qos common ops and platform
related stuff.

Our strategy would be:

a) Implement a platform glue driver (dwc_eth_qos_pltfm.c)
b) Implement a pci glue driver (dwc_eth_qos_pci.c)
c) Implement a "core driver" (dwc_eth_qos.c) that would only have Ethernet QoS
related stuff to be reused by the platform / pci drivers
d) Add a set of features to the "core driver" that we have available internally

Thanks,
Joao


> 
> Regards,
> 
> Ozgur Karatas
> 
> 2016-11-18 15:28 GMT+03:00 Joao Pinto <Joao.Pinto@synopsys.com>:
> 
>>
>> Dear all,
>>
>> My name is Joao Pinto and I work at Synopsys.
>> I am a kernel developer with special focus in mainline collaboration, both
>> Linux
>> and Buildroot. I was recently named one of the maintainers of the PCIe
>> Designware core driver and I was the author of the Designware UFS driver
>> stack.
>>
>> I am sending you this e-mail because you were the suggested contacts from
>> the
>> get_maintainers script concerning Ethernet drivers :).
>>
>> Currently I have the task to work on the mainline Ethernet QoS driver in
>> which
>> you are the author. The work would consist of the following:
>>
>> a) Separate the current driver in a Core driver (common ops) + platform
>> glue
>> driver + pci glue driver
>> b) Add features that are currently only available internally
>> c) Add specific phy support using the PHY framework
>>
>> I would also gladly be available to be its maintainer if you agree with it.
>>
>> It would be great to have your collaboration in the project if you are
>> available
>> to review the work in progress.
>>
>> Thank you and I am looking forward for your feedback!
>>
>> Joao Pinto
>>
> 
