From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2 net-next] net/vxlan: Fix kernel unaligned access in
 __vxlan_find_mac
Date: Mon, 20 Jul 2015 11:07:34 -0300
Message-ID: <20150720140733.GA4960@localhost.localdomain>
References: <20150720075450.GB20398@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, therbert@google.com,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, jiri@resnulli.us,
	jbenc@redhat.com, azhou@nicira.com, jesse@nicira.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150720075450.GB20398@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 20, 2015 at 09:54:50AM +0200, Sowmini Varadhan wrote:
> 
> __vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
> which triggers unaligned access messages, so rearrange vxlan_fdb
> to avoid this in the most non-intrusive way.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
