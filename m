From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net] ipv4:correct description for tcp_max_syn_backlog
Date: Tue, 06 Dec 2011 13:02:46 -0500 (EST)
Message-ID: <20111206.130246.1089940767987284936.davem@davemloft.net>
References: <4EDDC1D6.6000708@gmail.com>
	<ed04712f4f61e291ac784a8a77e2831981cfb9c1.1323156956.git.panweiping3@gmail.com>
	<20111206140709.GA29082@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, shanwei88@gmail.com, rdunlap@xenotime.net,
	eric.dumazet@gmail.com, shanwei@cn.fujitsu.com, makc@redhat.com,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20111206140709.GA29082@hmsreliant.think-freely.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 6 Dec 2011 09:07:09 -0500

> On Tue, Dec 06, 2011 at 03:39:41PM +0800, Weiping Pan wrote:
>> Since commit c5ed63d66f24(tcp: fix three tcp sysctls tuning),
>> sysctl_max_syn_backlog is determined by tcp_hashinfo->ehash_mask,
>> and the minimal value is 128, and it will increase in proportion to the
>> memory of machine.
>> The original description for tcp_max_syn_backlog and sysctl_max_syn_backlog
>> are out of date.
>> 
>> Changelog:
>> V2: update description for sysctl_max_syn_backlog
>> 
>> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks everyone.
