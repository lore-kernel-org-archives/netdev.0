From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Wed, 3 May 2017 11:07:03 +1000
Message-ID: <20170503110703.0945929d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>,
        =?UTF-8?B?SMOldmFyZA==?= Skinnemoen <hskinnemoen@gmail.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        Josh Hunt <johunt@akamai.com>,
        Sridhar Samudrala <sridhar.samudrala@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/avr32/include/uapi/asm/socket.h

between commit:

  26202873bb51 ("avr32: remove support for AVR32 architecture")

from Linus' tree and commits:

  a2d133b1d465 ("sock: introduce SO_MEMINFO getsockopt")
  6d4339028b35 ("net: Introduce SO_INCOMING_NAPI_ID"
  5daab9db7b65 ("New getsockopt option to get socket cookie")

from the net-next tree.

I fixed it up (I removed the file) and can carry the fix as
necessary. This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell
