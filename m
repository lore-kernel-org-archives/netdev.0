From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/2] netfilter: preparatory patches for set extensions
Date: Sat, 21 Mar 2015 15:38:08 +0000
Message-ID: <1426952290-18962-1-git-send-email-kaber@trash.net>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches contain some prepraration for nftables set extensions.
These extensions will allow to attach dynamically sized data to set
elements, thereby moving the key to a non-fixed position.

This requires nft_hash to use the rhashtable callbacks. Since the
key length is variable, the length must be provided to the obj_hashfn.

The patches change rhashtable to do so and do a conversion of nft_hash
to rhashtable callbacks without any functional changes.

@Dave and Pablo: these patches apply on top of nf-next and a bunch
of patches I just sent to Pablo, but also need Herbert's recent
changes in net-next. Additionally I have more patches coming up
which depend on these changes. In order to simplify things, I'd
suggest to have the rhashtable change go through Pablo's tree if
you don't mind.

Thanks!
