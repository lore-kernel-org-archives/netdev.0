From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 18:43:51 +0200
Message-ID: <5781419.24ZaHfTAxC@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <5133914.uYLb0gnNTc@localhost.localdomain> <1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54833 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757366Ab2BNQoh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:44:37 -0500
Received: by bkcjm19 with SMTP id jm19so152079bkc.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 08:44:35 -0800 (PST)
In-Reply-To: <1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=92=D1=82=D0=BE=D1=80=D0=BD=D0=B8=D0=BA 14 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 17:00:10 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 16:28 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> =C3=A9crit :
> > Yes, results are the same for 3.2.3 kernel with and without running
> > this command and for geographically close to me server (speed not l=
imited)
> > and for server not close to me speed limitation the same.
>=20
> I wonder if "netstat -s" is telling the truth ...
>=20
> Could you post after a transfert on 3.2, "grep TcpExt /proc/net/netst=
at"

Kernel 3.2.6 (2.6.42.6-3.fc15.i686):

Before downloading:
TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts Pr=
uneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFilt=
er TW TWRecycled TWKilled PAWSPassive=20
PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost Listen=
Overflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCo=
pyFromPrequeue TCPPrequeueDropped=20
TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSack=
Recovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder T=
CPTSReorder TCPFullUndo=20
TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRe=
noFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRet=
rans TCPSlowStartRetrans TCPTimeouts=20
TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollap=
sed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbo=
rtOnSyn TCPAbortOnData=20
TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger TCP=
AbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld TCPDSA=
CKIgnoredNoUndo=20
TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected TCPSackShifted TCPSackM=
erged TCPSackShiftFallback TCPBacklogDrop TCPMinTTLDrop TCPDeferAcceptD=
rop IPReversePathFilter=20
TCPTimeWaitOverflow TCPReqQFullDoCookies TCPReqQFullDrop
TcpExt: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0=
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 =
0 0 0 0 0 0 0 0 0 0 47 0 0 0

After downloading FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz with speed 5,8 M=
egabytes/s
TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts Pr=
uneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFilt=
er TW TWRecycled TWKilled PAWSPassive=20
PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost Listen=
Overflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCo=
pyFromPrequeue TCPPrequeueDropped=20
TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSack=
Recovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder T=
CPTSReorder TCPFullUndo=20
TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRe=
noFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRet=
rans TCPSlowStartRetrans TCPTimeouts=20
TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollap=
sed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbo=
rtOnSyn TCPAbortOnData=20
TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger TCP=
AbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld TCPDSA=
CKIgnoredNoUndo=20
TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected TCPSackShifted TCPSackM=
erged TCPSackShiftFallback TCPBacklogDrop TCPMinTTLDrop TCPDeferAcceptD=
rop IPReversePathFilter=20
TCPTimeWaitOverflow TCPReqQFullDoCookies TCPReqQFullDrop
TcpExt: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 11 0 0 0 0 0 2896 0 0 1426425 2=
 1 9 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 =
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 47 0 0 0


Kernel 3.1.10 (2.6.41.10-3.fc15.i686):

Before downloading:
TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts Pr=
uneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFilt=
er TW TWRecycled TWKilled PAWSPassive=20
PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost Listen=
Overflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCo=
pyFromPrequeue TCPPrequeueDropped=20
TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSack=
Recovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder T=
CPTSReorder TCPFullUndo=20
TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRe=
noFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRet=
rans TCPSlowStartRetrans TCPTimeouts=20
TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollap=
sed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbo=
rtOnSyn TCPAbortOnData=20
TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger TCP=
AbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld TCPDSA=
CKIgnoredNoUndo=20
TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected TCPSackShifted TCPSackM=
erged TCPSackShiftFallback TCPBacklogDrop TCPMinTTLDrop TCPDeferAcceptD=
rop IPReversePathFilter=20
TCPTimeWaitOverflow TCPReqQFullDoCookies TCPReqQFullDrop
TcpExt: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 99 0 15 0 0 0=
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 =
0 0 0 0 0 0 0 0 0 0 0 32 0 0 0

After downloading FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz with speed 11,2 =
Megabytes/s
TcpExt: SyncookiesSent SyncookiesRecv SyncookiesFailed EmbryonicRsts Pr=
uneCalled RcvPruned OfoPruned OutOfWindowIcmps LockDroppedIcmps ArpFilt=
er TW TWRecycled TWKilled PAWSPassive=20
PAWSActive PAWSEstab DelayedACKs DelayedACKLocked DelayedACKLost Listen=
Overflows ListenDrops TCPPrequeued TCPDirectCopyFromBacklog TCPDirectCo=
pyFromPrequeue TCPPrequeueDropped=20
TCPHPHits TCPHPHitsToUser TCPPureAcks TCPHPAcks TCPRenoRecovery TCPSack=
Recovery TCPSACKReneging TCPFACKReorder TCPSACKReorder TCPRenoReorder T=
CPTSReorder TCPFullUndo=20
TCPPartialUndo TCPDSACKUndo TCPLossUndo TCPLoss TCPLostRetransmit TCPRe=
noFailures TCPSackFailures TCPLossFailures TCPFastRetrans TCPForwardRet=
rans TCPSlowStartRetrans TCPTimeouts=20
TCPRenoRecoveryFail TCPSackRecoveryFail TCPSchedulerFailed TCPRcvCollap=
sed TCPDSACKOldSent TCPDSACKOfoSent TCPDSACKRecv TCPDSACKOfoRecv TCPAbo=
rtOnSyn TCPAbortOnData=20
TCPAbortOnClose TCPAbortOnMemory TCPAbortOnTimeout TCPAbortOnLinger TCP=
AbortFailed TCPMemoryPressures TCPSACKDiscard TCPDSACKIgnoredOld TCPDSA=
CKIgnoredNoUndo=20
TCPSpuriousRTOs TCPMD5NotFound TCPMD5Unexpected TCPSackShifted TCPSackM=
erged TCPSackShiftFallback TCPBacklogDrop TCPMinTTLDrop TCPDeferAcceptD=
rop IPReversePathFilter=20
TCPTimeWaitOverflow TCPReqQFullDoCookies TCPReqQFullDrop
TcpExt: 0 0 0 0 0 0 0 0 0 0 8 0 0 0 0 0 25 0 0 0 0 0 99912 0 0 1416306 =
69 16 9 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0=
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 0 0 0
