From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/2] af_packet: make tpacket_rcv to not set status
 value before run_filter
Date: Mon, 23 Mar 2015 22:01:37 -0400 (EDT)
Message-ID: <20150323.220137.841197773102664079.davem@davemloft.net>
References: <1426752102-12786-2-git-send-email-al.drozdov@gmail.com>
	<1427091073-8129-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, dborkman@redhat.com, edumazet@google.com,
	viro@zeniv.linux.org.uk, willemb@google.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tklauser@distanz.ch, linux-doc@vger.kernel.org,
	linux-api@vger.kernel.org
To: al.drozdov@gmail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1427091073-8129-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Drozdov <al.drozdov@gmail.com>
Date: Mon, 23 Mar 2015 09:11:12 +0300

> It is just an optimization. We don't need the value of status variable
> if the packet is filtered.
> 
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Applied to net-next
