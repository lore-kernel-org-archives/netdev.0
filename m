From: "MORANGE,DAMIEN (HP-France,ex1)" <damien.morange@hp.com>
Subject: [PATCH] lksctp 0.6.9 backport on 2.4.23-pre3
Date: Fri, 12 Sep 2003 15:45:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <B320F712053ED411869200D0B747A3CA0FE474E9@laplace.grenoble.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'samudrala@us.ibm.com'" <samudrala@us.ibm.com>,
   "'lksctp-developers@lists.sourceforge.net'" <lksctp-developers@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'linux-net@vger.kernel.org'" <linux-net@vger.kernel.org>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   "'davem@redhat.com'" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Catching up on moving 2.4.20+ target, here is a set of patches to backport
lksctp on top of 2.4.23-pre3[*], ready (IMHO) for integration into 2.4.x.

It consists in 3 patches, described in details (and referenced) below. They
are uploaded in the "Patches" section of the lksctp project page on
Sourceforge.

<http://sourceforge.net/tracker/?group_id=26529&atid=387572>

Comments welcome. Please Cc: lksctp-developers in reply, as I am not
currently subscribed to netdev.  TIA.

Best regards,

[*] it will not work on 2.4.20 & previous versions, as the required 
upward packet distribution was integrated between 2.4.20 & 2.4.21 and
onwards.
<http://linux.bkbits.net:8080/linux-2.4/user=sri/cset@1.930.35.4?nav=!-|inde
x.html|stats|!+|index.html|ChangeSet@-6M>



[1/3]  LKSCTP 0.6.9 backport on kernel 2.4.23-pre3

    This patch is the first of a bundle of 3.

    It adds the necessary changes to the kernel IP stack so that SCTP
    can perform PMTU discovery. No other SCTP-specific changes.

    This patch only affects existing kernel files. The resulting kernel
    is functionally unchanged.

    [1/3] lksctp 0.6.9 on kernel 2.4.23-pre3

 
<http://sourceforge.net/tracker/index.php?func=detail&aid=805060&group_id=26
529&atid=387572>


[2/3]  LKSCTP 0.6.9 backport on kernel 2.4.23-pre3

    This patch is the second of a bundle of 3.

    This patch modifies the kernel existing files to add the SCTP
    functionality. It cannot work without the 3rd patch of this serie,
    but is issued to better highlight the required changes.

    This patch requires the [1/3] patch. The kernel resulting from [2/3]
    patching will not compile, until [3/3] is also applied.

    [2/3] lksctp 0.6.9 on kernel 2.4.23-pre3

 
<http://sourceforge.net/tracker/index.php?func=detail&aid=805063&group_id=26
529&atid=387572>


[3/3]  LKSCTP 0.6.9 backport on kernel 2.4.23-pre3

    This patch is the 3rd of a bundle of 3.

    This patch consists only in new files, added for SCTP support. It
    adds the SCTP protocol & sockets layers to the IP stack.

    This patchs requires  patches [1/3] & [2/3] to be applied. A kernel
    resulting from the patching using the whole set of patch is a
2.4.23-pre3
    with SCTP support.

    [3/3] lksctp 0.6.9 on kernel 2.4.23-pre3

 
<http://sourceforge.net/tracker/index.php?func=detail&aid=805064&group_id=26
529&atid=387572>

PS:  This is the last version of a number of patchsets submitted to lksctp
team. Compared to the last series of patches we have produced on top of
2.4.22-rc2, there have been no functional changes but the
single_open()/single_release() interface changes that have been moved from
the compatibility header (include/net/sctp/compat.h) and exported in
kernel/ksyms.c


-- 
Damien Morange
