From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/9] openvswitch: Serialize acts with original
 netlink len
Date: Thu, 30 Jul 2015 21:35:30 +0200
Message-ID: <20150730193530.GA26187@pox.localdomain>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net, jpettit@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, jesse@nicira.com,
	fwestpha@redhat.com, hannes@redhat.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438279963-29563-3-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/15 at 11:12am, Joe Stringer wrote:
> Previously, we used the kernel-internal netlink actions length to
> calculate the size of messages to serialize back to userspace.
> However,the sw_flow_actions may not be formatted exactly the same as the
> actions on the wire, so store the original actions length when
> de-serializing and re-use the original length when serializing.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
