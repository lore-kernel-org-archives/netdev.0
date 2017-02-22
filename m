From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kspp tree with the net-next tree
Date: Wed, 22 Feb 2017 11:06:29 +1100
Message-ID: <20170222110629.53d01cf5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Laura Abbott <labbott@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Kees Cook <keescook@google.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the kspp tree got a conflict in:

  include/linux/filter.h

between commit:

  9d876e79df6a ("bpf: fix unlocking of jited image when module ronx not set")

from the net-next tree and commit:

  0f5bf6d0afe4 ("arch: Rename CONFIG_DEBUG_RODATA and CONFIG_DEBUG_MODULE_RONX")

from the kspp tree.

Hmmm, both these change the ifdef guards I have used the one from the
net-next tree (CONFIG_ARCH_HAS_SET_MEMORY) for today, please let me know
if that is not correct.

I fixed it up (see above) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell
