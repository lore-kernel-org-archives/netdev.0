From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 7/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 14:27:20 -0700
Message-ID: <20120911212720.GD7677@google.com>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
 <1347380774-9546-8-git-send-email-wagi@monom.org>
 <20120911210109.GZ7677@google.com>
 <504FA9D6.4050201@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63777 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757739Ab2IKV1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 17:27:25 -0400
Content-Disposition: inline
In-Reply-To: <504FA9D6.4050201@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Daniel

On Tue, Sep 11, 2012 at 11:15:02PM +0200, Daniel Wagner wrote:
> If net_prio_subsys_id is changed to be an enum, then the compiler
> will report an error:
> 
> error: lvalue required as left operand of assignment
> 
> that was the reason why I kept this change here. I think I just
> don't get what you are trying to tell me.
> 
> >Please separate these changes and explain them.
> 
> I will do that as soon I figured out what you are telling me.

Sorry about that.  I was thinking that was a separate variable.  Well,
we can introduce a variable, change the id allocation and then swap it
back to the constant, but that would be too much.  Let's just try to
explain it better.

Thanks.

-- 
tejun
