From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 05:43:13 +0100
Message-ID: <1329280993.2555.21.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <5133914.uYLb0gnNTc@localhost.localdomain>
	 <1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <5781419.24ZaHfTAxC@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62728 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757028Ab2BOEnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 23:43:18 -0500
Received: by wgbdt10 with SMTP id dt10so541411wgb.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 20:43:16 -0800 (PST)
In-Reply-To: <5781419.24ZaHfTAxC@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 18:43 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :
> =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=92=D1=82=D0=BE=D1=80=D0=BD=D0=B8=D0=BA 14 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 17:00:10 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> > Le mardi 14 f=C3=A9vrier 2012 =C3=A0 16:28 +0200, alekcejk@googlema=
il.com a
> >=20
> > =C3=A9crit :
> > > Yes, results are the same for 3.2.3 kernel with and without runni=
ng
> > > this command and for geographically close to me server (speed not=
 limited)
> > > and for server not close to me speed limitation the same.
> >=20
> > I wonder if "netstat -s" is telling the truth ...
> >=20
> > Could you post after a transfert on 3.2, "grep TcpExt /proc/net/net=
stat"
>=20
> Kernel 3.2.6 (2.6.42.6-3.fc15.i686):
>=20
> Before downloading:
> TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts =
PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFi=
lter TW TWRecycled TWKilled PAWSPassive=20
> PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost List=
enOverflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirect=
CopyFromPrequeue TCPPrequeueDropped=20
> TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSa=
ckRecovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder=
 TCPTSReorder TCPFullUndo=20
> TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCP=
RenoFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardR=
etrans TCPSlowStartRetrans TCPTimeouts=20
> TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvColl=
apsed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPA=
bortOnSyn TCPAbortOnData=20
> TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger T=
CPAbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld TCPD=
SACKIgnoredNoUndo=20
> TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected TCPSackShifted TCPSac=
kMerged TCPSackShiftFallback TCPBacklogDrop TCPMinTTLDrop TCPDeferAccep=
tDrop IPReversePathFilter=20
> TCPTimeWaitOverflow TCPReqQFullDoCookies TCPReqQFullDrop
> TcpExt: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0=
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 =
0 0 0 0 0 0 0 0 0 0 0 47 0 0 0
>=20
> After downloading FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz with speed 5,8=
 Megabytes/s
> TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts =
PruneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFi=
lter TW TWRecycled TWKilled PAWSPassive=20
> PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost List=
enOverflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirect=
CopyFromPrequeue TCPPrequeueDropped=20
> TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSa=
ckRecovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder=
 TCPTSReorder TCPFullUndo=20
> TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCP=
RenoFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardR=
etrans TCPSlowStartRetrans TCPTimeouts=20
> TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvColl=
apsed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPA=
bortOnSyn TCPAbortOnData=20
> TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger T=
CPAbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld TCPD=
SACKIgnoredNoUndo=20
> TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected TCPSackShifted TCPSac=
kMerged TCPSackShiftFallback TCPBacklogDrop TCPMinTTLDrop TCPDeferAccep=
tDrop IPReversePathFilter=20
> TCPTimeWaitOverflow TCPReqQFullDoCookies TCPReqQFullDrop
> TcpExt: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 11 0 0 0 0 0 2896 0 0 1426425=
 2 1 9 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 =
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 47 0 0 0
>=20
>=20

OK thanks, nothing seems wrong on receiver side.

Could you try to force ECN enabled flows and send tcpdump, to check if
we receive retransmits ?

echo 1 >/proc/sys/net/ipv4/tcp_ecn


And check tcp can engage ECN : tcpdump SYN/SYNACK should look like:

05:41:17.943538 IP 192.168.1.97.45986 > 68.232.35.119.80: Flags [SEW],
seq 2109565072, win 14600, options [mss 1460,sackOK,TS val 8295492 ecr
0,nop,wscale 6], length 0

05:41:17.980619 IP 68.232.35.119.80 > 192.168.1.97.45986: Flags [S.E],
seq 2519424885, ack 2109565073, win 14600, options [mss
1452,nop,nop,sackOK,nop,wscale 6], length 0

=2E..
