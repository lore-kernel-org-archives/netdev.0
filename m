From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 0/2 net-next] bridge: fix bugs introduced by last multicast patchset
Date: Thu, 12 Jun 2014 01:41:22 +0200
Message-ID: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once my last patchset got applied, I got slapped by an automatic smatch
and build bot. Here are two patches fixing the according issues, a potential
null pointer dereference and a compile error when compiling without IPv6.

[PATCH 1/2] is probably not the ideal solution - the assignment of the
group and max_delay is still a mess and has subtle differences between
IGMPv2, IGMPv3, MLDv1 and MLDv2. That should probably be fixed $later.
But for now, I think the easier fix might be better, restoring the
behaviour before my "adhere to querier mechanism" patch and therefore
keeping things bisect'able.

Cheers, Linus
