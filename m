From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPsec support
Date: Wed, 19 Feb 2003 16:37:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030219.163748.123408970.davem@redhat.com>
References: <20030218.233301.98333082.davem@redhat.com>
	<m3el645hv3.wl@karaba.org>
	<87bs17hnnm.wl@ipinfusion.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mk@karaba.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kunihiro@ipinfusion.com
In-Reply-To: <87bs17hnnm.wl@ipinfusion.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kunihiro Ishiguro <kunihiro@ipinfusion.com>
   Date: Wed, 19 Feb 2003 15:10:53 -0800
   
   But there changes are no needed.  Miyazaki, would you mind to take a
   look into this?  Have fun ;-).

Hello, I do not comment on your patch but on related issue which
must be remembered.

ipv6/xfrm_policy.c will go away, and we will move this code into
ipv4/xfrm_policy.c inside of an ipv4 ifdef protected area.

I will be taking all the ipv6 ipsec work I have merged and push it to
Linus right now.  Once he takes this, we may work from common source
base and begin to merge in new work.
