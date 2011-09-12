From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering support
 for passthru mode
Date: Sun, 11 Sep 2011 21:30:43 -0700
Message-ID: <4E6D8AF3.7080406@us.ibm.com>
References: <CA920319.33DE1%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	dragos.tatulea@gmail.com, arnd@arndb.de, dwang2@cisco.com,
	benve@cisco.com, kaber@trash.net, davem@davemloft.net,
	eric.dumazet@gmail.com, mchan@broadcom.com, kvm@vger.kernel.org
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CA920319.33DE1%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/11/2011 6:18 AM, Roopa Prabhu wrote:
>
>
> On 9/11/11 2:44 AM, "Michael S. Tsirkin"<mst@redhat.com>  wrote:
>
>>> AFAIK, though it might maintain a single filter table space in hw, hw does
>>> know which filter belongs to which VF. And the OS driver does not need to do
>>> anything special. The VF driver exposes a VF netdev. And any uc/mc addresses
>>> registered with a VF netdev are registered with the hw by the driver. And hw
>>> will filter and send only pkts that the VF has expressed interest in.
>>>
>>> No special filter partitioning in hw is required.
>>>
>>> Thanks,
>>> Roopa
>> Yes, but what I mean is, if the size of the single filter table
>> is limited, we need to decide how many addresses is
>> each guest allowed. If we let one guest ask for
>> as many as it wants, it can lock others out.
> Yes true. In these cases ie when the number of unicast addresses being
> registered is more than it can handle, The VF driver will put the VF  in
> promiscuous mode (Or at least its supposed to do. I think all drivers do
> that).
>
What does putting VF in promiscuous mode mean?  How can the NIC decide 
which set
of mac addresses are passed to the VF? Does it mean VF sees all the 
packets received
by the NIC including packets destined for other VFs/PF?

Thanks
Sridhar

