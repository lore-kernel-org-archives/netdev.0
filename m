From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: Multicast snooping fixes and suggestions
Date: Wed, 16 Feb 2011 00:19:16 +0100
Message-ID: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everyone,

While testing the (very awesome!) bridge igmp/mld snooping support I came across
two issues which are breaking IPv6 multicast snooping and IPv6
non-link-local multicast on bridges with multicast snooping support enabled
in general. The first two patches shall fix these issues.

The third one addresses a potential bug on little endian machines which I noticed
during this little code reviewing. This patch is untested though, feedback welcome.

The fourth and fifth patch are a suggestion to also permit using the bridge multicast
snooping feature for link local multimedia multicast traffic. Therefore
using the transient multicast flag instead of the non-link-local scope criteria
seems to be a suitable solution at least for IPv6, in my opinion. Let me know what
you think about it.

Thanks for reviewing these patches.

Cheers,
Linus
