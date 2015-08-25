From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv5 net-next 09/10] openvswitch: Allow matching on
 conntrack label
Date: Tue, 25 Aug 2015 20:29:59 +0200
Message-ID: <20150825182959.GM3707@pox.localdomain>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
 <1440462740-23358-10-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, jpettit@nicira.com,
	jesse@nicira.com, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440462740-23358-10-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/15 at 05:32pm, Joe Stringer wrote:
> Allow matching and setting the ct_label field. As with ct_mark, this is
> populated by executing the CT action. The label field may be modified by
> specifying a label and mask nested under the CT action. It is stored as
> metadata attached to the connection. Label modification occurs after
> lookup, and will only persist when the conntrack entry is committed by
> providing the COMMIT flag to the CT action. Labels are currently fixed
> to 128 bits in size.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
