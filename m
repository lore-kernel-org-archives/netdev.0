From: Sasha Levin <levinsasha928@gmail.com>
Subject: Wrong usage of hash in L2TP leading to NULL ptr derefs
Date: Mon, 28 May 2012 18:12:19 +0200
Message-ID: <1338221539.4284.25.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, jchapman@katalix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Looking at net/l2tp/l2tp_ip{6}.c, l2tp uses UDP for communications, but
uses inet_hash and inet_unhash for hashing - which appears to be wrong
(and causes NULL ptr derefs during runtime).

Since I'm not too familiar with the protocol, I'm not sure if the right
fix would be to switch it to use the UDP hashing code, or to actually
initialize everything inet_hash() expects so the current hashing would
work properly.

Help appreciated!

Thanks,
Sasha
