From: Ben Greear <greearb@candelatech.com>
Subject: How to enable more than ~256 routing tables?
Date: Tue, 22 Apr 2003 00:10:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EA4EAFD.5020808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I would like to have a routing table per interface, and would like to support
1k interfaces or so (virtual interfaces like vlans, for instance).

I notice in rtnetlink.h there is this code:

enum rt_class_t
{
	RT_TABLE_UNSPEC=0,
/* User defined values */
	RT_TABLE_DEFAULT=253,
	RT_TABLE_MAIN=254,
	RT_TABLE_LOCAL=255
};
#define RT_TABLE_MAX RT_TABLE_LOCAL


Is it possible to just change the RT_TABLE_MAX to be higher and have 256-????
be more /* User defined values */ ?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
