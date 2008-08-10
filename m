From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sun, 10 Aug 2008 12:57:20 -0500
Message-ID: <489F2C00.3080608@opengridcomputing.com>
References: <489CC58D.4010606@pobox.com>	<20080809.002840.167363463.davem@davemloft.net>	<adavdy9zc2k.fsf@cisco.com> <20080809.224725.130946315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, jgarzik@pobox.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080809.224725.130946315.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Sat, 09 Aug 2008 22:14:11 -0700
>
>   
>>  > Also, I find it ironic that the port abduction is being asked for in
>>  > order to be "compatible with existing tools" yet in fact this stuff
>>  > breaks everything.  You can't netfilter this traffic, you can't apply
>>  > qdiscs to it, you can't execut TC actions on them, you can't do
>>  > segmentation offload on them, you can't look for the usual TCP MIB
>>  > statistics on the connection, etc. etc. etc.
>>
>> We already support offloads that break other features, eg large receive
>> offload breaks forwarding.  We deal with it.
>>     
>
> We turn it off.  If I want to shape or filter one of these iSCSI
> connections can we turn it off?
>
>   
Sure.

Seems to me we _could_ architect this all so that these devices would 
have to support a method for the management/admin tools to tweak, and if 
nothing else kill, offload connections if policy rules change and the 
existing connections aren't implementing the policy.  IE: if the offload 
connection doesn't support whatever security or other facilities that 
the admin requires, then the admin should have the ability to disable 
that device.  And of course, some devices will allow doing things like 
netfilter, qos, tweaking vlan tags, etc even on active connection,  if 
the OS infrastructure is there to hook it all up.

BTW:  I think all these offload devices provide MIBs and could be pulled 
in to the normal management tools.


Steve.
