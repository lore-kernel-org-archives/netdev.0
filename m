From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 03 Mar 2009 05:02:19 -0700
Message-ID: <49AD1C4B.2000403@mlbassoc.com>
References: <20090227145746.GD17040@xi.wantstofly.org>	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>	 <20090227222802.GZ17040@xi.wantstofly.org>	 <1235991382.30736.62.camel@localhost.localdomain>	 <1235991937.30736.65.camel@localhost.localdomain>	 <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com>	 <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>	 <49AC5E6F.3010204@mlbassoc.com>	 <1236070372.30736.87.camel@localhost.localdomain> <1236071061.30736.94.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:1075 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbZCCMCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 07:02:46 -0500
In-Reply-To: <1236071061.30736.94.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Tue, 2009-03-03 at 09:52 +0100, Jesper Dangaard Brouer wrote:
>> On Mon, 2009-03-02 at 15:32 -0700, Gary Thomas wrote:
>>> Any ideas how I might troubleshoot why packets that come
>>> into lan1.1 (port 0) aren't being pushed to the CPU port?
>> The switch supports port monitoring, with seperate ingress and egress
>> mapping, thus you could place another PC on another port and direct
>> traffic towards that, and by tcpdump inspecting ingress and egress on
>> the different physical ports... Thats how I debugged it once...
>>
>> I also used/implemented the VLAN violation interrupt, while I debugged
>> the VLAN setup.   The switch also have a ATU (MAC-table) violation
>> interrupt, perhaps that might tell you something?
> 
> Another thing... An IXP425 specific change I had to make, was to disable
> NPE_learning for the ixp400_eth driver.
> 
>  insmod ixp400_eth npe_learning=0
> 
> MODULE_PARM_DESC(npe_learning, "If non-zero, NPE MAC Address Learning &
> Filtering feature will be enabled");
> 
> Perhaps the GIANFAR driver also has this kind of MAC address filtering?
> 

I don't think this is a problem; no packets are getting
[back] to the gianfar interface (based on RX interrupt counts)

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
