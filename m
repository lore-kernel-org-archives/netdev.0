From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
 buffer is large enough
Date: Tue, 4 Mar 2014 13:30:04 -0800
Message-ID: <20140304133004.b565820f60f595a48e621e58@linux-foundation.org>
References: <8738j3vzry.fsf@xmission.com>
	<20140301011142.GK16640@madcap2.tricolour.ca>
	<87fvn2r0yb.fsf@xmission.com>
	<874n3ir0uw.fsf_-_@xmission.com>
	<87mwhaplo4.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Guy Briggs <rgb@redhat.com>,
	Eric Paris <eparis@redhat.com>, linux-audit@redhat.com,
	linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mwhaplo4.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Feb 2014 20:50:19 -0800 ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> Modify audit_send_reply to directly use a non-blocking send and
> to return an error on failure (if anyone cares).
> 
> Modify audit_list_rules_send to use audit_send_reply and give up
> if we can not send a packet.
> 
> Merge audit_list_rules into iaudit_list_rules_send as the code
> is now sufficiently simple to not justify to callers.
> 
> Kill audit_send_list, audit_send_reply_thread because using
> a separate thread for replies is not needed when sending
> packets syncrhonously.

Nothing much seems to be happening here?

In an earlier email you said "While reading through 3.14-rc1 I found a
pretty siginficant mishandling of network namespaces in the recent
audit changes." Were those recent audit changes a post-3.14 thing?  And
what is the user-visible effect of the mishandling?

Thanks.
