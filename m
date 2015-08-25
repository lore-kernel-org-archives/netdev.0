From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv5 net-next 06/10] openvswitch: Allow matching on
 conntrack mark
Date: Tue, 25 Aug 2015 20:27:04 +0200
Message-ID: <20150825182704.GK3707@pox.localdomain>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
 <1440462740-23358-7-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, jpettit@nicira.com,
	jesse@nicira.com, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440462740-23358-7-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/15 at 05:32pm, Joe Stringer wrote:
> Allow matching and setting the ct_mark field. As with ct_state and
> ct_zone, these fields are populated when the CT action is executed. To
> write to this field, a value and mask can be specified as a nested
> attribute under the CT action. This data is stored with the conntrack
> entry, and is executed after the lookup occurs for the CT action. The
> conntrack entry itself must be committed using the COMMIT flag in the CT
> action flags for this change to persist.
> 
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
