From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Thu, 15 May 2014 13:43:28 -0400 (EDT)
Message-ID: <20140515.134328.221963981846625223.davem@davemloft.net>
References: <20140515164703.73a1cf06@canb.auug.org.au>
	<CAM_iQpU84BD4WjTEW0Yn6-R3ocHh25quAj_F8cmkVK=CRZd9Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpU84BD4WjTEW0Yn6-R3ocHh25quAj_F8cmkVK=CRZd9Kg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 15 May 2014 10:39:20 -0700

> On Wed, May 14, 2014 at 11:47 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> Hi all,
>>
>> After merging the net-next tree, today's linux-next build (powerpc
>> allnoconfig) produced this warning:
>>
>>
>> include/net/ip.h:211:5: warning: "CONFIG_SYSCTL" is not defined [-Wundef]
>>  #if CONFIG_SYSCTL
>>      ^
>>
>> Introduced by commit 122ff243f5f1 ("ipv4: make ip_local_reserved_ports
>> per netns").
> 
> 
> Oops, blame my fat fingers... Just s/#if/#ifdef/. ;)

I've just pushed out a fix for this, thanks everyone.
