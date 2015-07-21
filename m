From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/vxlan: Fix kernel unaligned access in
 __vxlan_find_mac
Date: Tue, 21 Jul 2015 00:12:56 -0700 (PDT)
Message-ID: <20150721.001256.2277736594553600193.davem@davemloft.net>
References: <20150720075450.GB20398@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com, marcelo.leitner@gmail.com,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, jiri@resnulli.us,
	jbenc@redhat.com, azhou@nicira.com, jesse@nicira.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150720075450.GB20398@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 20 Jul 2015 09:54:50 +0200

> 
> __vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
> which triggers unaligned access messages, so rearrange vxlan_fdb
> to avoid this in the most non-intrusive way.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: Alexander Duyck comments: place eth_addr[] to be 64b aligned

Applied, thanks.
