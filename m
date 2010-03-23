From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch 3/3] bonding: make bonding support netpoll
Date: Tue, 23 Mar 2010 09:49:16 +0800
Message-ID: <4BA81E1C.7070400@redhat.com>
References: <20100322082059.4967.63492.sendpatchset@localhost.localdomain> <20100322082123.4967.77433.sendpatchset@localhost.localdomain> <20100323005639.GH2108@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100323005639.GH2108@gospo.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> On Mon, Mar 22, 2010 at 04:17:40AM -0400, Amerigo Wang wrote:
>> Based on Andy's work, but I modify a lot.
>>
>> Similar to the patch for bridge, this patch does:
>>
>> 1) implement the 4 methods to support netpoll for bonding;
>>
>> 2) modify netpoll during forwarding packets in bonding;
>>
>> 3) disable netpoll support of bridge when a netpoll-unabled device
>>    is added to bonding;
>>
>> 4) enable netpoll support when all underlying devices support netpoll.
>>
>> Cc: Andy Gospodarek <gospo@redhat.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: David Miller <davem@davemloft.net>
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>>
> 
> How much testing was done on this?
> 
> One of the potential problems with this code is how gracefully the
> system can handle tear-down of interfaces or removal of the bonding
> module when netconsole is active.  Was that tested heavily?
> 

For this case you mention, I did test it, but what I did is mainly basic
functionality testing, including bonding over bridge and bridge over bonding.

Thanks!
