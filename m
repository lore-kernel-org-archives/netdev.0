From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack: Batch cleanup
Date: Tue, 19 Mar 2013 23:53:19 +0100
Message-ID: <20130319225319.GA3669@localhost>
References: <1363254014-10725-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@openvz.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Vladimir Davydov <vdavydov@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363254014-10725-1-git-send-email-vdavydov@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 14, 2013 at 01:40:14PM +0400, Vladimir Davydov wrote:
> The patch introduces nf_conntrack_cleanup_net_list(), which cleanups
> nf_conntrack for a list of netns and calls synchronize_net() only once
> for them all. This should reduce netns destruction time.

Applied, thanks.
