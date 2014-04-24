From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 24 Apr 2014 17:11:55 -0400 (EDT)
Message-ID: <20140424.171155.806959282091051918.davem@davemloft.net>
References: <20140424203427.GC19091@redhat.com>
	<20140424.164820.1543648508330465096.davem@davemloft.net>
	<20140424210429.GD19091@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, tj@kernel.org, dwalsh@redhat.com,
	linux-kernel@vger.kernel.org, lpoetter@redhat.com,
	ssorce@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	netdev@vger.kernel.org
To: vgoyal@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140424210429.GD19091@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivek Goyal <vgoyal@redhat.com>
Date: Thu, 24 Apr 2014 17:04:29 -0400

> Does it really matter.

Good question, if it doesn't matter, you might as well log garbage.

There are a lot of logical holes in this discussion.

Real UIDs are always reported at sendmsg() time, not effective ones
(the UID "at sendmsg() time").

Therefore if we were to add CGROUP passing at sendmsg() time it should
report the "real cgroup", the one the task has at the time the file
descriptor / socket was "created".
