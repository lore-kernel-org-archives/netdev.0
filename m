From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: [ANNOUNCE] new lksctp release lksctp-2_5_29-0_5_0
Date: Wed, 31 Jul 2002 13:07:10 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <16520.3841556378$1028139199@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: linux-kernel@vgr.kernel.org.sgi.com
List-Id: netdev.vger.kernel.org

Linux Kernel SCTP Release lksctp-2_5_29-0_5_0 is now available 
for download.  


The lksctp project was created to develop a Linux kernel implementation 
of the SCTP transport protocol.  


For more information, as well as, source tarballs and patches, please 
visit: 
     
        http://www.sourceforge.net/projects/lksctp/ 

The linux-2.5.29 based patch can be downloaded directly from:


http://prdownloads.sourceforge.net/lksctp/lksctp-2_5_29-0_5_0.patch?download


Best Regards, 
Jon Grimm 


The most recent CHANGES are as follows:

lksctp-2_5_29-0_5_0:
Patch 588249 misc. user header file fixes (jgrimm)

lksctp-2_5_29-0_4_99:
Patch 582166 sctp_peeloff() support. (samudrala)
Bug   583874 sendmsg/init with bad buf. has leak (jgrimm)
Patch 581963 Handle select/poll syscalls (daisyc)
Bug   583798 Need GFP_ATOMIC when BH disabled (samudrala)
Bug   585351 MSG_UNORDERED not set on fragmented chunks (samudrala)
Patch 585474 Remove old DEFAULT_STREAM sock opt (jgrimm)
Bug   585653 Fix V6INADDR_ANY to choose a saddr (jgrimm)
Bug   585929 more leaks in sendmsg() on error cases. (samudrala)
Patch 574420 overlapping init/restart  (dajiang, jgrimm)
Bug   581992 zero probe shouldn't error association (samudrala)
Patch 587986 move to Linux 2.5.29 (samudrala)

lksctp-2_5_24-0_4_12:
Patch 569943 graceful shutdown of an individual association. (samudrala)
Patch 572054 move to linux kernel 2.5.24. (samudrala)
Bug   574069 bugs in fragmentation & reassembly. (samudrala)
Patch 579301 check for No User Data error and testcase (jgrimm)
Bug   574071 less strict rwnd check at rcvr (samudrala)
Patch 579525 SCTP_AUTOCLOSE socket option. (samudrala)
Patch 575712 modify sctp_darn tool to use select (daisyc)
NA           misc.: cleanup jiffies decl., update docs. (jgrimm) 
Patch 581745 getsockname needs sk->sport (jgrimm)
Patch 582273 handle DATA while in SHUTDOWN-SENT (jgrimm)
Bug   581997 sctp_wait_for_sndbuf fault (jgrimm)
Patch 573958 Overlapping Init testcases (dajiang)
Patch 582905 misc: remove md5 files. update cause code values (jgrimm)
