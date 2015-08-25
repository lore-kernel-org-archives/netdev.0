From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv5 net-next 01/10] openvswitch: Serialize acts with
 original netlink len
Date: Tue, 25 Aug 2015 20:23:04 +0200
Message-ID: <20150825182304.GH3707@pox.localdomain>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
 <1440462740-23358-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, jpettit@nicira.com,
	jesse@nicira.com, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440462740-23358-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/15 at 05:32pm, Joe Stringer wrote:
> Previously, we used the kernel-internal netlink actions length to
> calculate the size of messages to serialize back to userspace.
> However,the sw_flow_actions may not be formatted exactly the same as the
> actions on the wire, so store the original actions length when
> de-serializing and re-use the original length when serializing.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
