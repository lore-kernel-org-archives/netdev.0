From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Wed, 14 Jan 2004 14:52:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401141450.43806.mashirle@us.ibm.com>
References: <200312021240.PAA01536@yakov.inr.ac.ru> <200312051214.48076.mashirle@us.ibm.com> <20031205123133.3743fe39.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_3W4IHK7H5IB4D0GPKYUU"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031205123133.3743fe39.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_3W4IHK7H5IB4D0GPKYUU
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> "sizeof(unsigned long)" evaluates to 8 on 64-bit systems,
> yet you assume it always evaluated to 4 as on 32-bit systems.
>
> Maybe it would be wiser to explicitly use 'u32' and 'u64' for
> the types of the snmp counters?
>
> This has always been a sore area.

This is the new patch against 2.6.1 kernel.

Thanks
Shirley Ma
IBM Linux Technology Center
--------------Boundary-00=_3W4IHK7H5IB4D0GPKYUU
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.1-ipv6mib2-64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.1-ipv6mib2-64.patch"

diff -urN linux-2.6.1/include/net/snmp.h linux-2.6.1-ipv6mib2-64/include/net/snmp.h
--- linux-2.6.1/include/net/snmp.h	2004-01-08 22:59:26.000000000 -0800
+++ linux-2.6.1-ipv6mib2-64/include/net/snmp.h	2004-01-13 13:45:23.000000000 -0800
@@ -49,24 +49,24 @@
  */
 struct ip_mib
 {
- 	unsigned long	IpInReceives;
- 	unsigned long	IpInHdrErrors;
- 	unsigned long	IpInAddrErrors;
- 	unsigned long	IpForwDatagrams;
- 	unsigned long	IpInUnknownProtos;
- 	unsigned long	IpInDiscards;
- 	unsigned long	IpInDelivers;
- 	unsigned long	IpOutRequests;
- 	unsigned long	IpOutDiscards;
- 	unsigned long	IpOutNoRoutes;
- 	unsigned long	IpReasmTimeout;
- 	unsigned long	IpReasmReqds;
- 	unsigned long	IpReasmOKs;
- 	unsigned long	IpReasmFails;
- 	unsigned long	IpFragOKs;
- 	unsigned long	IpFragFails;
- 	unsigned long	IpFragCreates;
-	unsigned long   __pad[0]; 
+ 	__u64	IpInReceives;
+ 	__u64	IpInHdrErrors;
+ 	__u64	IpInAddrErrors;
+ 	__u64	IpForwDatagrams;
+ 	__u64	IpInUnknownProtos;
+ 	__u64	IpInDiscards;
+ 	__u64	IpInDelivers;
+ 	__u64	IpOutRequests;
+ 	__u64	IpOutDiscards;
+ 	__u64	IpOutNoRoutes;
+ 	__u64	IpReasmTimeout;
+ 	__u64	IpReasmReqds;
+ 	__u64	IpReasmOKs;
+ 	__u64	IpReasmFails;
+ 	__u64	IpFragOKs;
+ 	__u64	IpFragFails;
+ 	__u64	IpFragCreates;
+	__u64   __pad[0]; 
 };
  
 /*
@@ -74,29 +74,29 @@
  */
 struct ipv6_mib
 {
-	unsigned long	Ip6InReceives;
- 	unsigned long	Ip6InHdrErrors;
- 	unsigned long	Ip6InTooBigErrors;
- 	unsigned long	Ip6InNoRoutes;
- 	unsigned long	Ip6InAddrErrors;
- 	unsigned long	Ip6InUnknownProtos;
- 	unsigned long	Ip6InTruncatedPkts;
- 	unsigned long	Ip6InDiscards;
- 	unsigned long	Ip6InDelivers;
- 	unsigned long	Ip6OutForwDatagrams;
- 	unsigned long	Ip6OutRequests;
- 	unsigned long	Ip6OutDiscards;
- 	unsigned long	Ip6OutNoRoutes;
- 	unsigned long	Ip6ReasmTimeout;
- 	unsigned long	Ip6ReasmReqds;
- 	unsigned long	Ip6ReasmOKs;
- 	unsigned long	Ip6ReasmFails;
- 	unsigned long	Ip6FragOKs;
- 	unsigned long	Ip6FragFails;
- 	unsigned long	Ip6FragCreates;
- 	unsigned long	Ip6InMcastPkts;
- 	unsigned long	Ip6OutMcastPkts;
-	unsigned long   __pad[0]; 
+	__u64	Ip6InReceives;
+ 	__u64	Ip6InHdrErrors;
+ 	__u64	Ip6InTooBigErrors;
+ 	__u64	Ip6InNoRoutes;
+ 	__u64	Ip6InAddrErrors;
+ 	__u64	Ip6InUnknownProtos;
+ 	__u64	Ip6InTruncatedPkts;
+ 	__u64	Ip6InDiscards;
+ 	__u64	Ip6InDelivers;
+ 	__u64	Ip6OutForwDatagrams;
+ 	__u64	Ip6OutRequests;
+ 	__u64	Ip6OutDiscards;
+ 	__u64	Ip6OutNoRoutes;
+ 	__u64	Ip6ReasmTimeout;
+ 	__u64	Ip6ReasmReqds;
+ 	__u64	Ip6ReasmOKs;
+ 	__u64	Ip6ReasmFails;
+ 	__u64	Ip6FragOKs;
+ 	__u64	Ip6FragFails;
+ 	__u64	Ip6FragCreates;
+ 	__u64	Ip6InMcastPkts;
+ 	__u64	Ip6OutMcastPkts;
+	__u64   __pad[0]; 
 };
  
 /*
@@ -105,34 +105,34 @@
  */
 struct icmp_mib
 {
- 	unsigned long	IcmpInMsgs;
- 	unsigned long	IcmpInErrors;
-  	unsigned long	IcmpInDestUnreachs;
- 	unsigned long	IcmpInTimeExcds;
- 	unsigned long	IcmpInParmProbs;
- 	unsigned long	IcmpInSrcQuenchs;
- 	unsigned long	IcmpInRedirects;
- 	unsigned long	IcmpInEchos;
- 	unsigned long	IcmpInEchoReps;
- 	unsigned long	IcmpInTimestamps;
- 	unsigned long	IcmpInTimestampReps;
- 	unsigned long	IcmpInAddrMasks;
- 	unsigned long	IcmpInAddrMaskReps;
- 	unsigned long	IcmpOutMsgs;
- 	unsigned long	IcmpOutErrors;
- 	unsigned long	IcmpOutDestUnreachs;
- 	unsigned long	IcmpOutTimeExcds;
- 	unsigned long	IcmpOutParmProbs;
- 	unsigned long	IcmpOutSrcQuenchs;
- 	unsigned long	IcmpOutRedirects;
- 	unsigned long	IcmpOutEchos;
- 	unsigned long	IcmpOutEchoReps;
- 	unsigned long	IcmpOutTimestamps;
- 	unsigned long	IcmpOutTimestampReps;
- 	unsigned long	IcmpOutAddrMasks;
- 	unsigned long	IcmpOutAddrMaskReps;
-	unsigned long	dummy;
-	unsigned long   __pad[0]; 
+ 	__u64	IcmpInMsgs;
+ 	__u64	IcmpInErrors;
+  	__u64	IcmpInDestUnreachs;
+ 	__u64	IcmpInTimeExcds;
+ 	__u64	IcmpInParmProbs;
+ 	__u64	IcmpInSrcQuenchs;
+ 	__u64	IcmpInRedirects;
+ 	__u64	IcmpInEchos;
+ 	__u64	IcmpInEchoReps;
+ 	__u64	IcmpInTimestamps;
+ 	__u64	IcmpInTimestampReps;
+ 	__u64	IcmpInAddrMasks;
+ 	__u64	IcmpInAddrMaskReps;
+ 	__u64	IcmpOutMsgs;
+ 	__u64	IcmpOutErrors;
+ 	__u64	IcmpOutDestUnreachs;
+ 	__u64	IcmpOutTimeExcds;
+ 	__u64	IcmpOutParmProbs;
+ 	__u64	IcmpOutSrcQuenchs;
+ 	__u64	IcmpOutRedirects;
+ 	__u64	IcmpOutEchos;
+ 	__u64	IcmpOutEchoReps;
+ 	__u64	IcmpOutTimestamps;
+ 	__u64	IcmpOutTimestampReps;
+ 	__u64	IcmpOutAddrMasks;
+ 	__u64	IcmpOutAddrMaskReps;
+	__u64	dummy;
+	__u64	__pad[0]; 
 };
 
 /*
@@ -140,40 +140,35 @@
  */
 struct icmpv6_mib
 {
-	unsigned long	Icmp6InMsgs;
-	unsigned long	Icmp6InErrors;
-
-	unsigned long	Icmp6InDestUnreachs;
-	unsigned long	Icmp6InPktTooBigs;
-	unsigned long	Icmp6InTimeExcds;
-	unsigned long	Icmp6InParmProblems;
-
-	unsigned long	Icmp6InEchos;
-	unsigned long	Icmp6InEchoReplies;
-	unsigned long	Icmp6InGroupMembQueries;
-	unsigned long	Icmp6InGroupMembResponses;
-	unsigned long	Icmp6InGroupMembReductions;
-	unsigned long	Icmp6InRouterSolicits;
-	unsigned long	Icmp6InRouterAdvertisements;
-	unsigned long	Icmp6InNeighborSolicits;
-	unsigned long	Icmp6InNeighborAdvertisements;
-	unsigned long	Icmp6InRedirects;
-
-	unsigned long	Icmp6OutMsgs;
-
-	unsigned long	Icmp6OutDestUnreachs;
-	unsigned long	Icmp6OutPktTooBigs;
-	unsigned long	Icmp6OutTimeExcds;
-	unsigned long	Icmp6OutParmProblems;
-
-	unsigned long	Icmp6OutEchoReplies;
-	unsigned long	Icmp6OutRouterSolicits;
-	unsigned long	Icmp6OutNeighborSolicits;
-	unsigned long	Icmp6OutNeighborAdvertisements;
-	unsigned long	Icmp6OutRedirects;
-	unsigned long	Icmp6OutGroupMembResponses;
-	unsigned long	Icmp6OutGroupMembReductions;
-	unsigned long   __pad[0]; 
+	__u64	Icmp6InMsgs;
+	__u64	Icmp6InErrors;
+	__u64	Icmp6InDestUnreachs;
+	__u64	Icmp6InPktTooBigs;
+	__u64	Icmp6InTimeExcds;
+	__u64	Icmp6InParmProblems;
+	__u64	Icmp6InEchos;
+	__u64	Icmp6InEchoReplies;
+	__u64	Icmp6InGroupMembQueries;
+	__u64	Icmp6InGroupMembResponses;
+	__u64	Icmp6InGroupMembReductions;
+	__u64	Icmp6InRouterSolicits;
+	__u64	Icmp6InRouterAdvertisements;
+	__u64	Icmp6InNeighborSolicits;
+	__u64	Icmp6InNeighborAdvertisements;
+	__u64	Icmp6InRedirects;
+	__u64	Icmp6OutMsgs;
+	__u64	Icmp6OutDestUnreachs;
+	__u64	Icmp6OutPktTooBigs;
+	__u64	Icmp6OutTimeExcds;
+	__u64	Icmp6OutParmProblems;
+	__u64	Icmp6OutEchoReplies;
+	__u64	Icmp6OutRouterSolicits;
+	__u64	Icmp6OutNeighborSolicits;
+	__u64	Icmp6OutNeighborAdvertisements;
+	__u64	Icmp6OutRedirects;
+	__u64	Icmp6OutGroupMembResponses;
+	__u64	Icmp6OutGroupMembReductions;
+	__u64   __pad[0]; 
 };
  
 /*
@@ -182,21 +177,21 @@
  */
 struct tcp_mib
 {
- 	unsigned long	TcpRtoAlgorithm;
- 	unsigned long	TcpRtoMin;
- 	unsigned long	TcpRtoMax;
- 	unsigned long	TcpMaxConn;
- 	unsigned long	TcpActiveOpens;
- 	unsigned long	TcpPassiveOpens;
- 	unsigned long	TcpAttemptFails;
- 	unsigned long	TcpEstabResets;
- 	unsigned long	TcpCurrEstab;
- 	unsigned long	TcpInSegs;
- 	unsigned long	TcpOutSegs;
- 	unsigned long	TcpRetransSegs;
- 	unsigned long	TcpInErrs;
- 	unsigned long	TcpOutRsts;
-	unsigned long   __pad[0]; 
+ 	__u64	TcpRtoAlgorithm;
+ 	__u64	TcpRtoMin;
+ 	__u64	TcpRtoMax;
+ 	__u64	TcpMaxConn;
+ 	__u64	TcpActiveOpens;
+ 	__u64	TcpPassiveOpens;
+ 	__u64	TcpAttemptFails;
+ 	__u64	TcpEstabResets;
+ 	__u64	TcpCurrEstab;
+ 	__u64	TcpInSegs;
+ 	__u64	TcpOutSegs;
+ 	__u64	TcpRetransSegs;
+ 	__u64	TcpInErrs;
+ 	__u64	TcpOutRsts;
+	__u64   __pad[0]; 
 };
  
 /*
@@ -205,110 +200,110 @@
  */
 struct udp_mib
 {
- 	unsigned long	UdpInDatagrams;
- 	unsigned long	UdpNoPorts;
- 	unsigned long	UdpInErrors;
- 	unsigned long	UdpOutDatagrams;
-	unsigned long   __pad[0];
+ 	__u64	UdpInDatagrams;
+ 	__u64	UdpNoPorts;
+ 	__u64	UdpInErrors;
+ 	__u64	UdpOutDatagrams;
+	__u64   __pad[0];
 }; 
 
 /* draft-ietf-sigtran-sctp-mib-07.txt */
 struct sctp_mib
 {
-	unsigned long   SctpCurrEstab;
-	unsigned long   SctpActiveEstabs;
-	unsigned long   SctpPassiveEstabs;
-	unsigned long   SctpAborteds;
-	unsigned long   SctpShutdowns;
-	unsigned long   SctpOutOfBlues;
-	unsigned long   SctpChecksumErrors;
-	unsigned long   SctpOutCtrlChunks;
-	unsigned long   SctpOutOrderChunks;
-	unsigned long   SctpOutUnorderChunks;
-	unsigned long   SctpInCtrlChunks;
-	unsigned long   SctpInOrderChunks;
-	unsigned long   SctpInUnorderChunks;
-	unsigned long   SctpFragUsrMsgs;
-	unsigned long   SctpReasmUsrMsgs;
-	unsigned long   SctpOutSCTPPacks;
-	unsigned long   SctpInSCTPPacks;
-	unsigned long   SctpRtoAlgorithm;
-	unsigned long   SctpRtoMin;
-	unsigned long   SctpRtoMax;
-	unsigned long   SctpRtoInitial;
-	unsigned long   SctpValCookieLife;
-	unsigned long   SctpMaxInitRetr;
-	unsigned long   __pad[0];
+	__u64   SctpCurrEstab;
+	__u64   SctpActiveEstabs;
+	__u64   SctpPassiveEstabs;
+	__u64   SctpAborteds;
+	__u64   SctpShutdowns;
+	__u64   SctpOutOfBlues;
+	__u64   SctpChecksumErrors;
+	__u64   SctpOutCtrlChunks;
+	__u64   SctpOutOrderChunks;
+	__u64   SctpOutUnorderChunks;
+	__u64   SctpInCtrlChunks;
+	__u64   SctpInOrderChunks;
+	__u64   SctpInUnorderChunks;
+	__u64   SctpFragUsrMsgs;
+	__u64   SctpReasmUsrMsgs;
+	__u64   SctpOutSCTPPacks;
+	__u64   SctpInSCTPPacks;
+	__u64   SctpRtoAlgorithm;
+	__u64   SctpRtoMin;
+	__u64   SctpRtoMax;
+	__u64   SctpRtoInitial;
+	__u64   SctpValCookieLife;
+	__u64   SctpMaxInitRetr;
+	__u64   __pad[0];
 };
 
 struct linux_mib 
 {
-	unsigned long	SyncookiesSent;
-	unsigned long	SyncookiesRecv;
-	unsigned long	SyncookiesFailed;
-	unsigned long	EmbryonicRsts;
-	unsigned long	PruneCalled; 
-	unsigned long	RcvPruned;
-	unsigned long	OfoPruned;
-	unsigned long	OutOfWindowIcmps; 
-	unsigned long	LockDroppedIcmps; 
-        unsigned long   ArpFilter;
-	unsigned long	TimeWaited; 
-	unsigned long	TimeWaitRecycled; 
-	unsigned long	TimeWaitKilled; 
-	unsigned long	PAWSPassiveRejected; 
-	unsigned long	PAWSActiveRejected; 
-	unsigned long	PAWSEstabRejected; 
-	unsigned long	DelayedACKs;
-	unsigned long	DelayedACKLocked;
-	unsigned long	DelayedACKLost;
-	unsigned long	ListenOverflows;
-	unsigned long	ListenDrops;
-	unsigned long	TCPPrequeued;
-	unsigned long	TCPDirectCopyFromBacklog;
-	unsigned long	TCPDirectCopyFromPrequeue;
-	unsigned long	TCPPrequeueDropped;
-	unsigned long	TCPHPHits;
-	unsigned long	TCPHPHitsToUser;
-	unsigned long	TCPPureAcks;
-	unsigned long	TCPHPAcks;
-	unsigned long	TCPRenoRecovery;
-	unsigned long	TCPSackRecovery;
-	unsigned long	TCPSACKReneging;
-	unsigned long	TCPFACKReorder;
-	unsigned long	TCPSACKReorder;
-	unsigned long	TCPRenoReorder;
-	unsigned long	TCPTSReorder;
-	unsigned long	TCPFullUndo;
-	unsigned long	TCPPartialUndo;
-	unsigned long	TCPDSACKUndo;
-	unsigned long	TCPLossUndo;
-	unsigned long	TCPLoss;
-	unsigned long	TCPLostRetransmit;
-	unsigned long	TCPRenoFailures;
-	unsigned long	TCPSackFailures;
-	unsigned long	TCPLossFailures;
-	unsigned long	TCPFastRetrans;
-	unsigned long	TCPForwardRetrans;
-	unsigned long	TCPSlowStartRetrans;
-	unsigned long	TCPTimeouts;
-	unsigned long	TCPRenoRecoveryFail;
-	unsigned long	TCPSackRecoveryFail;
-	unsigned long	TCPSchedulerFailed;
-	unsigned long	TCPRcvCollapsed;
-	unsigned long	TCPDSACKOldSent;
-	unsigned long	TCPDSACKOfoSent;
-	unsigned long	TCPDSACKRecv;
-	unsigned long	TCPDSACKOfoRecv;
-	unsigned long	TCPAbortOnSyn;
-	unsigned long	TCPAbortOnData;
-	unsigned long	TCPAbortOnClose;
-	unsigned long	TCPAbortOnMemory;
-	unsigned long	TCPAbortOnTimeout;
-	unsigned long	TCPAbortOnLinger;
-	unsigned long	TCPAbortFailed;
-	unsigned long	TCPMemoryPressures;
-	unsigned long   __pad[0];
+	__u64	SyncookiesSent;
+	__u64	SyncookiesRecv;
+	__u64	SyncookiesFailed;
+	__u64	EmbryonicRsts;
+	__u64	PruneCalled; 
+	__u64	RcvPruned;
+	__u64	OfoPruned;
+	__u64	OutOfWindowIcmps; 
+	__u64	LockDroppedIcmps; 
+	__u64   ArpFilter;
+	__u64	TimeWaited; 
+	__u64	TimeWaitRecycled; 
+	__u64	TimeWaitKilled; 
+	__u64	PAWSPassiveRejected; 
+	__u64	PAWSActiveRejected; 
+	__u64	PAWSEstabRejected; 
+	__u64	DelayedACKs;
+	__u64	DelayedACKLocked;
+	__u64	DelayedACKLost;
+	__u64	ListenOverflows;
+	__u64	ListenDrops;
+	__u64	TCPPrequeued;
+	__u64	TCPDirectCopyFromBacklog;
+	__u64	TCPDirectCopyFromPrequeue;
+	__u64	TCPPrequeueDropped;
+	__u64	TCPHPHits;
+	__u64	TCPHPHitsToUser;
+	__u64	TCPPureAcks;
+	__u64	TCPHPAcks;
+	__u64	TCPRenoRecovery;
+	__u64	TCPSackRecovery;
+	__u64	TCPSACKReneging;
+	__u64	TCPFACKReorder;
+	__u64	TCPSACKReorder;
+	__u64	TCPRenoReorder;
+	__u64	TCPTSReorder;
+	__u64	TCPFullUndo;
+	__u64	TCPPartialUndo;
+	__u64	TCPDSACKUndo;
+	__u64	TCPLossUndo;
+	__u64	TCPLoss;
+	__u64	TCPLostRetransmit;
+	__u64	TCPRenoFailures;
+	__u64	TCPSackFailures;
+	__u64	TCPLossFailures;
+	__u64	TCPFastRetrans;
+	__u64	TCPForwardRetrans;
+	__u64	TCPSlowStartRetrans;
+	__u64	TCPTimeouts;
+	__u64	TCPRenoRecoveryFail;
+	__u64	TCPSackRecoveryFail;
+	__u64	TCPSchedulerFailed;
+	__u64	TCPRcvCollapsed;
+	__u64	TCPDSACKOldSent;
+	__u64	TCPDSACKOfoSent;
+	__u64	TCPDSACKRecv;
+	__u64	TCPDSACKOfoRecv;
+	__u64	TCPAbortOnSyn;
+	__u64	TCPAbortOnData;
+	__u64	TCPAbortOnClose;
+	__u64	TCPAbortOnMemory;
+	__u64	TCPAbortOnTimeout;
+	__u64	TCPAbortOnLinger;
+	__u64	TCPAbortFailed;
+	__u64	TCPMemoryPressures;
+	__u64   __pad[0];
 };
 
 
diff -urN linux-2.6.1/net/ipv4/proc.c linux-2.6.1-ipv6mib2-64/net/ipv4/proc.c
--- linux-2.6.1/net/ipv4/proc.c	2004-01-08 22:59:05.000000000 -0800
+++ linux-2.6.1-ipv6mib2-64/net/ipv4/proc.c	2004-01-13 14:06:51.000000000 -0800
@@ -87,21 +87,21 @@
 	.release = single_release,
 };
 
-static unsigned long
+static __u64 
 fold_field(void *mib[], int nr)
 {
-	unsigned long res = 0;
+	__u64 res = 0;
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++) {
 		if (!cpu_possible(i))
 			continue;
 		res +=
-		    *((unsigned long *) (((void *) per_cpu_ptr(mib[0], i)) +
-					 sizeof (unsigned long) * nr));
+		    *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) +
+					 sizeof (__u64) * nr));
 		res +=
-		    *((unsigned long *) (((void *) per_cpu_ptr(mib[1], i)) +
-					 sizeof (unsigned long) * nr));
+		    *((__u64 *) (((void *) per_cpu_ptr(mib[1], i)) +
+					 sizeof (__u64) * nr));
 	}
 	return res;
 }
@@ -121,8 +121,8 @@
 			ipv4_devconf.forwarding ? 1 : 2, sysctl_ip_default_ttl);
 
 	for (i = 0;
-	     i < offsetof(struct ip_mib, __pad) / sizeof(unsigned long); i++)
-		seq_printf(seq, " %lu",
+	     i < offsetof(struct ip_mib, __pad) / sizeof(__u64); i++)
+		seq_printf(seq, " %llu",
 			   fold_field((void **) ip_statistics, i));
 
 	seq_printf(seq, "\nIcmp: InMsgs InErrors InDestUnreachs InTimeExcds "
@@ -134,8 +134,8 @@
 			"OutAddrMasks OutAddrMaskReps\nIcmp:");
 
 	for (i = 0;
-	     i < offsetof(struct icmp_mib, dummy) / sizeof(unsigned long); i++)
-		seq_printf(seq, " %lu",
+	     i < offsetof(struct icmp_mib, dummy) / sizeof(__u64); i++)
+		seq_printf(seq, " %llu",
 			   fold_field((void **) icmp_statistics, i)); 
 
 	seq_printf(seq, "\nTcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens "
@@ -143,13 +143,13 @@
 			"InSegs OutSegs RetransSegs InErrs OutRsts\nTcp:");
 
 	for (i = 0;
-	     i < offsetof(struct tcp_mib, __pad) / sizeof(unsigned long); i++) {
-		if (i == (offsetof(struct tcp_mib, TcpMaxConn) / sizeof(unsigned long)))
+	     i < offsetof(struct tcp_mib, __pad) / sizeof(__u64); i++) {
+		if (i == (offsetof(struct tcp_mib, TcpMaxConn) / sizeof(__u64)))
 			/* MaxConn field is negative, RFC 2012 */
 			seq_printf(seq, " %ld", 
-				   fold_field((void **) tcp_statistics, i));
+				  (long int)fold_field((void **) tcp_statistics, i));
 		else
-			seq_printf(seq, " %lu", 
+			seq_printf(seq, " %llu", 
 				   fold_field((void **) tcp_statistics, i));
 	}
 
@@ -157,8 +157,8 @@
 			"Udp:");
 
 	for (i = 0;
-	     i < offsetof(struct udp_mib, __pad) / sizeof(unsigned long); i++)
-		seq_printf(seq, " %lu", 
+	     i < offsetof(struct udp_mib, __pad) / sizeof(__u64); i++)
+		seq_printf(seq, " %llu", 
 				fold_field((void **) udp_statistics, i));
 
 	seq_putc(seq, '\n');
@@ -214,9 +214,9 @@
 		      " TCPAbortFailed TCPMemoryPressures\n"
 		      "TcpExt:");
 	for (i = 0;
-	     i < offsetof(struct linux_mib, __pad) / sizeof(unsigned long); 
+	     i < offsetof(struct linux_mib, __pad) / sizeof(__u64); 
 	     i++)
-		seq_printf(seq, " %lu", 
+		seq_printf(seq, " %llu", 
 		 	   fold_field((void **) net_statistics, i)); 
 	seq_putc(seq, '\n');
 	return 0;
diff -urN linux-2.6.1/net/ipv6/proc.c linux-2.6.1-ipv6mib2-64/net/ipv6/proc.c
--- linux-2.6.1/net/ipv6/proc.c	2004-01-08 22:59:26.000000000 -0800
+++ linux-2.6.1-ipv6mib2-64/net/ipv6/proc.c	2004-01-12 16:21:43.000000000 -0800
@@ -60,13 +60,14 @@
 struct snmp6_item
 {
 	char *name;
+	int   size;
 	int   offset;
 };
-#define SNMP6_SENTINEL	{ .name = NULL, .offset = 0 }
+#define SNMP6_SENTINEL	{ .name = NULL, .size = 0, .offset = 0 }
 
 static struct snmp6_item snmp6_ipv6_list[] = {
 /* ipv6 mib according to RFC 2465 */
-#define SNMP6_GEN(x) { .name = #x , .offset = offsetof(struct ipv6_mib, x) }
+#define SNMP6_GEN(x) { .name = #x , .size = sizeof(((struct ipv6_mib *)0)->x), .offset = offsetof(struct ipv6_mib, x) }
 	SNMP6_GEN(Ip6InReceives),
 	SNMP6_GEN(Ip6InHdrErrors),
 	SNMP6_GEN(Ip6InTooBigErrors),
@@ -104,7 +105,7 @@
 		OutRouterAdvertisements too.
 		OutGroupMembQueries too.
  */
-#define SNMP6_GEN(x) { .name = #x , .offset = offsetof(struct icmpv6_mib, x) }
+#define SNMP6_GEN(x) { .name = #x , .size = sizeof(((struct icmpv6_mib *)0)->x), .offset = offsetof(struct icmpv6_mib, x) }
 	SNMP6_GEN(Icmp6InMsgs),
 	SNMP6_GEN(Icmp6InErrors),
 	SNMP6_GEN(Icmp6InDestUnreachs),
@@ -138,7 +139,7 @@
 };
 
 static struct snmp6_item snmp6_udp6_list[] = {
-#define SNMP6_GEN(x) { .name = "Udp6" #x , .offset = offsetof(struct udp_mib, Udp##x) }
+#define SNMP6_GEN(x) { .name = "Udp6" #x , .size = sizeof(((struct udp_mib *)0)->Udp##x), .offset = offsetof(struct udp_mib, Udp##x) }
 	SNMP6_GEN(InDatagrams),
 	SNMP6_GEN(NoPorts),
 	SNMP6_GEN(InErrors),
@@ -147,22 +148,27 @@
 	SNMP6_SENTINEL
 };
 
-static unsigned long
-fold_field(void *mib[], int offt)
+static __u64 
+fold_field(void *mib[], int size, int offt)
 {
-        unsigned long res = 0;
+        __u64 res = 0;
         int i;
  
         for (i = 0; i < NR_CPUS; i++) {
                 if (!cpu_possible(i))
                         continue;
-                res +=
-                    *((unsigned long *) (((void *)per_cpu_ptr(mib[0], i)) +
-                                         offt));
-                res +=
-                    *((unsigned long *) (((void *)per_cpu_ptr(mib[1], i)) +
-                                         offt));
-        }
+		if (size == 4) {
+			res += *((__u32 *) 
+				(((void *)per_cpu_ptr(mib[0], i)) + offt));
+			res += *((__u32 *)
+				(((void *)per_cpu_ptr(mib[1], i)) + offt));
+		} else if (size == 8) {
+			res += *((__u64 *) 
+				(((void *)per_cpu_ptr(mib[0], i)) + offt));
+			res += *((__u32 *)
+				(((void *)per_cpu_ptr(mib[1], i)) + offt));
+		}
+	}
         return res;
 }
 
@@ -170,9 +176,9 @@
 snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp6_item *itemlist)
 {
 	int i;
-	for (i=0; itemlist[i].name; i++)
-		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name, 
-				fold_field(mib, itemlist[i].offset));
+	for (i=0; itemlist[i].name; i++) 
+		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name, 
+			fold_field(mib, itemlist[i].size, itemlist[i].offset));
 }
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)
diff -urN linux-2.6.1/net/sctp/proc.c linux-2.6.1-ipv6mib2-64/net/sctp/proc.c
--- linux-2.6.1/net/sctp/proc.c	2004-01-08 22:59:26.000000000 -0800
+++ linux-2.6.1-ipv6mib2-64/net/sctp/proc.c	2004-01-13 13:57:12.000000000 -0800
@@ -64,21 +64,21 @@
 /* Return the current value of a particular entry in the mib by adding its
  * per cpu counters.
  */ 
-static unsigned long
+static __u64
 fold_field(void *mib[], int nr)
 {
-	unsigned long res = 0;
+	__u64 res = 0;
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++) {
 		if (!cpu_possible(i))
 			continue;
 		res +=
-		    *((unsigned long *) (((void *) per_cpu_ptr(mib[0], i)) +
-					 sizeof (unsigned long) * nr));
+		    *((__u64 *) (((void *) per_cpu_ptr(mib[0], i)) +
+					 sizeof (__u64) * nr));
 		res +=
-		    *((unsigned long *) (((void *) per_cpu_ptr(mib[1], i)) +
-					 sizeof (unsigned long) * nr));
+		    *((__u64 *) (((void *) per_cpu_ptr(mib[1], i)) +
+					 sizeof (__u64) * nr));
 	}
 	return res;
 }
@@ -89,7 +89,7 @@
 	int i;
 
 	for (i = 0; i < sizeof(sctp_snmp_list) / sizeof(char *); i++)
-		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i],
+		seq_printf(seq, "%-32s\t%llu\n", sctp_snmp_list[i],
 			   fold_field((void **)sctp_statistics, i));
 
 	return 0;

--------------Boundary-00=_3W4IHK7H5IB4D0GPKYUU--
