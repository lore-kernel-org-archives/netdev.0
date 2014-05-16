From: Marc Duponcheel <marc@offline.be>
Subject: Re: r8169/r8168 slow internet upload
Date: Fri, 16 May 2014 04:55:27 +0200
Message-ID: <20140516025527.GA27212@offline.be>
References: <20140511231946.GA12504@offline.be>
 <20140512054447.GA17153@electric-eye.fr.zoreil.com>
 <20140513005023.GA24091@offline.be>
 <20140514220304.GA7520@electric-eye.fr.zoreil.com>
 <20140516020441.GB25757@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.offline.be ([79.132.231.86]:36975 "EHLO mail.offline.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbaEPCzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 22:55:25 -0400
Content-Disposition: inline
In-Reply-To: <20140516020441.GB25757@offline.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is TCP nstat after some time (days) of normal. mixed user traffic

 are TcpRetransSegs and TcpOutRsts reasonable ?

Thanks

opteron ~ # nstat | grep ^Tcp
TcpActiveOpens                  218771             0.0
TcpPassiveOpens                 245187             0.0
TcpAttemptFails                 961                0.0
TcpEstabResets                  1803               0.0
TcpInSegs                       5539041            0.0
TcpOutSegs                      5883556            0.0
TcpRetransSegs                  38828              0.0
TcpOutRsts                      369036             0.0
TcpExtSyncookiesFailed          112                0.0
TcpExtEmbryonicRsts             802                0.0
TcpExtTW                        218409             0.0
TcpExtPAWSEstab                 5                  0.0
TcpExtDelayedACKs               32173              0.0
TcpExtDelayedACKLocked          50                 0.0
TcpExtDelayedACKLost            1052               0.0
TcpExtListenDrops               7                  0.0
TcpExtTCPPrequeued              216710             0.0
TcpExtTCPDirectCopyFromBacklog  2218150            0.0
TcpExtTCPDirectCopyFromPrequeue 31007060           0.0
TcpExtTCPHPHits                 1189383            0.0
TcpExtTCPHPHitsToUser           23700              0.0
TcpExtTCPPureAcks               1265234            0.0
TcpExtTCPHPAcks                 1373386            0.0
TcpExtTCPSackRecovery           10161              0.0
TcpExtTCPSACKReneging           1                  0.0
TcpExtTCPFullUndo               2                  0.0
TcpExtTCPDSACKUndo              4                  0.0
TcpExtTCPLossUndo               103                0.0
TcpExtTCPLostRetransmit         23                 0.0
TcpExtTCPSackFailures           7                  0.0
TcpExtTCPLossFailures           46                 0.0
TcpExtTCPFastRetrans            29705              0.0
TcpExtTCPForwardRetrans         144                0.0
TcpExtTCPSlowStartRetrans       186                0.0
TcpExtTCPTimeouts               914                0.0
TcpExtTCPLossProbes             2094               0.0
TcpExtTCPLossProbeRecovery      250                0.0
TcpExtTCPSackRecoveryFail       63                 0.0
TcpExtTCPSchedulerFailed        1                  0.0
TcpExtTCPDSACKOldSent           1041               0.0
TcpExtTCPDSACKOfoSent           55                 0.0
TcpExtTCPDSACKRecv              967                0.0
TcpExtTCPAbortOnData            1520               0.0
TcpExtTCPAbortOnClose           185                0.0
TcpExtTCPAbortOnTimeout         256                0.0
TcpExtTCPDSACKIgnoredNoUndo     85                 0.0
TcpExtTCPSpuriousRTOs           11                 0.0
TcpExtTCPSackShifted            28438              0.0
TcpExtTCPSackMerged             26733              0.0
TcpExtTCPSackShiftFallback      32560              0.0
TcpExtTCPDeferAcceptDrop        335                0.0
TcpExtIPReversePathFilter       24                 0.0
TcpExtTCPRetransFail            114                0.0
TcpExtTCPRcvCoalesce            338862             0.0
TcpExtTCPOFOQueue               5712               0.0
TcpExtTCPOFOMerge               55                 0.0
TcpExtTCPChallengeACK           20                 0.0
TcpExtTCPSpuriousRtxHostQueues  463                0.0
TcpExtTCPAutoCorking            48213              0.0

--
 Marc Duponcheel
 Velodroomstraat 74 - 2600 Berchem - Belgium
 +32 (0)478 68.10.91 - marc@offline.be
