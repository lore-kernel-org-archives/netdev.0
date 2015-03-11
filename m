From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH RFC 0/4] Add support for async socket operations
Date: Wed, 11 Mar 2015 15:46:08 -0700
Message-ID: <20150311224607.23777.2181.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After the iocb parameter has been removed from sendmsg() and recvmsg() ops
the socket layer, and the network stack no longer support async operations.
This patch set adds support for asynchronous operations on sockets back.

--
Tadeusz Struk (4):
      net: socket: add support for async operations
      aio: prefer aio_op op over inter_op
      crypto: af_alg - Allow to link sgl
      crypto: algif - change algif_skcipher to be asynchronous


 crypto/af_alg.c         |   18 +++-
 crypto/algif_skcipher.c |  224 ++++++++++++++++++++++++++++++++++++++++++++++-
 fs/aio.c                |    8 +-
 include/crypto/if_alg.h |    4 +
 include/linux/net.h     |    8 ++
 net/socket.c            |   64 +++++++++++++
 6 files changed, 312 insertions(+), 14 deletions(-)

-- 
