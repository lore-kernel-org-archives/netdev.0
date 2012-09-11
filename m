From: Daniel Wagner <wagi@monom.org>
Subject: Re: [PATCH v3 7/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 23:31:45 +0200
Message-ID: <504FADC1.4060503@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org> <1347380774-9546-8-git-send-email-wagi@monom.org> <20120911210109.GZ7677@google.com> <20120911210821.GB7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:60579 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758048Ab2IKVbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 17:31:47 -0400
In-Reply-To: <20120911210821.GB7677@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2012 11:08 PM, Tejun Heo wrote:
> On Tue, Sep 11, 2012 at 02:01:09PM -0700, Tejun Heo wrote:
>> For example, it's not evident the above is correct and it's burried
>> with all other changes.  Can't we just assign the fixed subsys ID to
>> net_prio_subsys_id in this patch?  This patch would be correct without
>> any netprio changes, no?
>
> Oops, that was wrong.  net_prio_subsys_id itself becomes constant.
> Let's please better explain why the RCU trick removal is safe then.

In the last paragraph in the commit message I tried to document why it 
is safe to remove the RCU trick. Not good enough?
