From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] XFRM policy expire
Date: Wed, 25 Feb 2004 00:18:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225001809.7d27dd8d.davem@redhat.com>
References: <403B14DA.3000700@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <mludvig@suse.cz>
In-Reply-To: <403B14DA.3000700@suse.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Feb 2004 10:09:46 +0100
Michal Ludvig <mludvig@suse.cz> wrote:

> the attached patch fixes a bug in xfrm_send_policy_notify(). The space 
> allocated in skb must include 'sizeof(struct xfrm_user_polexpire)', not 
> 'sizeof(struct xfrm_userpolicy_info)' which is shorter. On ia32 it 
> worked, probably because of some space gained from aligning. 
> Unfortunately on amd64 it didn't and finally led to BUG() & kernel hangup.

Applied, thanks Michal.

> BTW The second patch attached does some obvious cleanup: replaces 
> RTA_ALIGN(RTA_LENGTH(x)) with RTA_SPACE(x) and ditto for NLMSG_*() 
> macros. Apply on top of the first one or drop it. It's up to you.

This is fine too, also applied.

Thanks again.
