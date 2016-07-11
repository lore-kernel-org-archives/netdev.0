From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: prevent bugcheck if filter truncates packet
 too much
Date: Mon, 11 Jul 2016 12:43:48 -0700 (PDT)
Message-ID: <20160711.124348.2217222752892197777.davem@davemloft.net>
References: <20160708155233.C78AAA0ECC@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samanthakumar@google.com, marco.gra@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160708155233.C78AAA0ECC@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri,  8 Jul 2016 17:52:33 +0200 (CEST)

> If socket filter truncates an udp packet below the length of UDP header
> in udpv6_queue_rcv_skb() or udp_queue_rcv_skb(), it will trigger a
> BUG_ON in skb_pull_rcsum(). This BUG_ON (and therefore a system crash if
> kernel is configured that way) can be easily enforced by an unprivileged
> user which was reported as CVE-2016-6162. For a reproducer, see
> http://seclists.org/oss-sec/2016/q3/8
> 
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Reported-by: Marco Grassi <marco.gra@gmail.com>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied and queued up for -stable, thanks.
