From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Sun, 11 Sep 2011 06:18:01 -0700
Message-ID: <CA920319.33DE1%roprabhu@cisco.com>
References: <20110911094449.GF27096@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, <netdev@vger.kernel.org>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>, <dwang2@cisco.com>,
	<benve@cisco.com>, <kaber@trash.net>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110911094449.GF27096@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 9/11/11 2:44 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:

>> 
>> AFAIK, though it might maintain a single filter table space in hw, hw does
>> know which filter belongs to which VF. And the OS driver does not need to do
>> anything special. The VF driver exposes a VF netdev. And any uc/mc addresses
>> registered with a VF netdev are registered with the hw by the driver. And hw
>> will filter and send only pkts that the VF has expressed interest in.
>> 
>> No special filter partitioning in hw is required.
>> 
>> Thanks,
>> Roopa
> 
> Yes, but what I mean is, if the size of the single filter table
> is limited, we need to decide how many addresses is
> each guest allowed. If we let one guest ask for
> as many as it wants, it can lock others out.

Yes true. In these cases ie when the number of unicast addresses being
registered is more than it can handle, The VF driver will put the VF  in
promiscuous mode (Or at least its supposed to do. I think all drivers do
that).


Thanks,
Roopa


