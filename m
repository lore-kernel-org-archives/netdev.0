From: "David S. Miller" <davem@davemloft.net>
Subject: Kconfig NET_EMATCH_TEXT
Date: Thu, 23 Jun 2005 21:05:08 -0700 (PDT)
Message-ID: <20050623.210508.10293826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Shouldn't there be some dependency between NET_EMATCH_TEXT and
TEXTSEARCH so that the user gets the right thing to happen if he
enables the former?

For IPSEC we do this by making things like INET_ESP depend upon
CRYPTO, CRYPTO_HMAC, CRYPTO_MD5, etc.  see net/ipv4/Kconfig
