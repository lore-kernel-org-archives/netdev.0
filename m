From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: [ANNOUNCE] New lksctp release:  lksctp-2_5_15-0_4_9
Date: Tue, 28 May 2002 09:53:14 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <ad0660$crn$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "lksctp-developers@lists.sourceforge.net"
 <lksctp-developers@lists.sourceforge.net>
List-Id: netdev.vger.kernel.org

Linux Kernel SCTP Developer Release lksctp-2_5_15-0_4_9 is now available
for download. 

The lksctp project was created to develop a Linux kernel implementation
of the SCTP transport protocol.  

For more information, as well as, source tarballs and patches, please
visit:
    
	http://www.sourceforge.net/projects/lksctp/

Best Regards,
Jon Grimm


The following is the list of changes since the last public release 

lksctp-2_5_15-0_4_9:
Patch 554705 Locking phase 1 (off the BH, use socklock and backlog)
(jgrimm) 
Bug   550363 Shutdown handling of CTSN incorrect (jgrimm)
Patch 558565 testframe ipv4 only, doesn't compile (samudarala)
Patch 556572 Fix INADDR_ANY and some IPv4 scoping (daisyc)
Patch 559801 Cleanup old locking stuff and various naming/style (jgrimm)

lksctp-2_5_15-0_4_8:
Patch 557034 Port to 2.5.15 (samudrala)
Patch 550903 sys_bindx removal (inaky, samudarala)

Mon May 20 08:55:12 CDT 2002
lksctp-2_4_18-0_4_8:
Patch 546328 sctp_transport cleanup (jgrimm)
Bug   545852 sk->err cleanup (samudrala)
Bug   547147 association leaks the inqueue->in_progress chunk (jgrimm)
Bug   541065 fix port_rover race conditition in bind path (jgrimm)
Patch 544577 heartbeat ack and failover (dajiang)
NA           Make lksctp a module (inaky)
NA           bindx over sockopt (inaky)
Patch 547885 Split out v6 code and cleanup module patch (jgrimm)
Patch 544583 ft_frame_hbACK updates (dajiang, huang)
Patch 547340 fix testframe for "run once" (samudrala)
Patch 548772 sctp_lock primitives   (jgrimm)
Patch 547319 naming cleanup in statefuns (daisyc)
Patch 549266 sctp_lock unittests (jgrimm)
Patch 548815 Disable fragments option and more tests. (samudrala)
Patch 550400 Add OOTB testcase (daisyc)
Patch 550520 transport & association error thresholds (samudrala)
NA           fix ft_frame_init_timer to not conflict with OOTB (jgrimm)
Patch 549356 Small fixes and cleanup of bindx code (inaky)
Patch 549360 bindx through sockopt (inaky)
Patch 551716 Start using sctp_opts field instead of endpoint (jgrimm)
Patch 551657 RTT Measurements and RTO updates (samudrala)
Patch 552084 sctp_endpoint_common (jgrimm)
Patch 553100 Testcase for RTT Measurements (samudrala)
Bug   553329 Sendmsg + INIT CMSG has path which can corrupt assoc
(jgrimm) 
Patch 553394 Move sctp_association to use endpoint_common (jgrimm)
Patch 553528 rtx and heartbeat failures cleanup (samudrala)
Patch 553844 OOTB packet processing (daisyc)

Fri Apr 19 10:47:41 CDT 2002
lksctp-2_4_18-0_4_7:
Bug   541198 Old-style retval->state races with CMD (jgrimm)
Patch 541820 listen auto-bind support (samudrala) 
Patch 543421 Complete removal of retval structs/processing (jgrimm)
Patch 544908 Object Count Debugging facilities (jgrimm)
Patch 544806 Fix inqueue leak of chunks (daisyc)
Patch 544460 Fragmentation/Reassembly support (samudrala)
