From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Thu, 20 Aug 2015 12:57:34 +1000
Message-ID: <20150820125734.51414bd0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

net/ipv4/fib_semantics.c: In function 'fib_encap_match':
net/ipv4/fib_semantics.c:553:3: error: implicit declaration of function 'lwtstate_free' [-Werror=implicit-function-declaration]
   lwtstate_free(lwtstate);
   ^

Caused by commit

  df383e6240ef ("lwtunnel: fix memory leak")

CONFIG_LWTUNNEL is not set for this build.

I reverted that commit for today.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
