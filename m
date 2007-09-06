From: Divy Le Ray <divy@chelsio.com>
Subject: net-26.24 broken with XFRM off
Date: Thu, 06 Sep 2007 00:25:51 -0700
Message-ID: <46DFAB7F.7060406@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	takamiya@po.ntts.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754063AbXIFH1n@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I get this error compiling net-2.6.24 with XFRM off:

[root@aries net-2.6.24]# make O=/opt/build/net-2.6.24
fatal: corrupted pack file 
.git/objects/pack/pack-39c494e9d4c6488e5911ee5c06926450679e6b78.pack
fatal: corrupted pack file 
.git/objects/pack/pack-39c494e9d4c6488e5911ee5c06926450679e6b78.pack
  Using /mnt/net-2.6.24 as source for kernel
  GEN     /opt/build/net-2.6.24/Makefile
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    /mnt/net-2.6.24/scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  GEN     .version
  CHK     include/linux/compile.h
  UPD     include/linux/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
net/built-in.o(.text+0x73ac2): In function `inet6_csk_xmit':
: undefined reference to `flow_cache_genid'
net/built-in.o(.text+0x73b9e): In function `inet6_csk_xmit':
: undefined reference to `flow_cache_genid'
make[1]: *** [.tmp_vmlinux1] Error 1
make: *** [_all] Error 2

I believe this commit introduced it:
commit a85d5450ddeb959bdf9e4603f9c06e9d79217cfa
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Fri Aug 24 23:31:39 2007 -0700

    [IPV6] XFRM: Fix connected socket to use transformation.

Cheers,
Divy
   
