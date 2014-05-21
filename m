From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: bridge: multicast snooping patches / exports
Date: Wed, 21 May 2014 10:58:58 +0200
Message-ID: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The first patch is simply a cosmetic patch. So far I (and maybe others
too?) have been regularly confusing these two structs, therefore I'd
suggest renaming them and therefore making the follow-up patches easier
to understand and nicer to fit in.

The second patch fixes a minor issue, but probably not worth for stable.


On the other hand the first two patches are also preparations for the
third and fourth patch:

These two patches are exporting functionality needed to marry the bridge
multicast snooping with the batman-adv multicast optimizations recently
added for the 3.15 kernel, allowing to use these optimzations in common
setups having a bridge on top of e.g. bat0, too. So far these bridged
setups would fall back to simple flooding through the batman-adv mesh
network for any multicast packet entering bat0.

More information about the batman-adv multicast optimizations currently
implemented can be found here:

http://www.open-mesh.org/projects/batman-adv/wiki/Basic-multicast-optimizations

The integration on the batman-adv side could afterwards look like this,
for instance:

http://git.open-mesh.org/batman-adv.git/commitdiff/576b59dd3e34737c702e548b21fa72059262f796?hp=f95ce7131746c65fbcdffcf2089cab59e2c2f7ac

Cheers, Linus
