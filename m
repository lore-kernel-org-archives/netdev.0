From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCHES] 2.4.x net driver updates
Date: Tue, 17 Jun 2003 18:34:10 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3EEF9762.2040900@pobox.com>
References: <20030612194926.GA7653@gtf.org> <20030617222750.GE13990@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20030617222750.GE13990@werewolf.able.es>
List-Id: netdev.vger.kernel.org

J.A. Magallon wrote:
> On 06.12, Jeff Garzik wrote:
> 
>>BK users may issue a
>>
>>	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.4
>>
>>Others may download the patch from
>>
>>ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.4/2.4.21-rc8-netdrvr2.patch.bz2
>>
> 
> 
> Any info about the RX_POLLING (NAPI) option for e1000 ?
> What is that for ?


NAPI enables a software polling mode, or software interrupt migitation 
if you prefer to call it that.  It kicks in at moderate to high packet 
rates, allows the net stack to more globally balance net traffic, and 
avoids problems associated with high packet load / DoS situations which 
would otherwise max out a cpu.

But it's a new feature, so being conservative there is a staged rollout, 
with NAPI support in e100[0] being an option that can be turned off. 
Some drivers like tg3 simply always enable NAPI.

	Jeff
