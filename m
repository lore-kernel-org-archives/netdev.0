From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 11:39:14 -0500
Message-ID: <fcb2d79550b4.480493e2@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov> <fb8e9e4f102e.47f8ebfd@fnal.gov>
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
 <000301c89e81$80124570$6b5ee183@D2GT6T71>
 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:54469 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754813AbYDOQoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 12:44:12 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZD00KAIJEW6P@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Tue, 15 Apr 2008 11:39:15 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041511391500430 for
 <netdev@vger.kernel.org>; Tue, 15 Apr 2008 11:39:15 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZD00K01KTTJ9@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 15 Apr 2008 11:39:15 -0500 (CDT)
In-reply-to: <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My fault, resent.
 
> Sill the mystery remains as to why *both* are going so slowly.  You
> mentioned you're using a web100 kernel.  What are the final values of
> all the variables for the connections (grab with readall)?

kernel 2.6.24

"echo 1 > /proc/sys/net/ipv4/tcp_no_metric_save"

..............................................................................................
WIth SACK On, throughput: 179Mbps

Connection 4 (198.2.1.2 56648  131.225.2.16 5001)
State                1
SACKEnabled          3
TimestampsEnabled    1
NagleEnabled         1
ECNEnabled           0
SndWinScale          11
RcvWinScale          7
ActiveOpen           1
MSSRcvd              0
WinScaleRcvd         11
WinScaleSent         7
PktsOut              154770
DataPktsOut          154770
DataBytesOut         226294264
PktsIn               149398
DataPktsIn           0
DataBytesIn          0
SndUna               930060039
SndNxt               930060039
SndMax               930060039
ThruBytesAcked       224092186
SndISS               705967853
RcvNxt               4282199280
ThruBytesReceived    0
RecvISS              4282199280
StartTimeSec         1208277286
StartTimeUsec        813964
Duration             13984145
SndLimTransSender    3
SndLimBytesSender    7208
SndLimTimeSender     3107
SndLimTransCwnd      2
SndLimBytesCwnd      226287056
SndLimTimeCwnd       10003734
SndLimTransRwin      0
SndLimBytesRwin      0
SndLimTimeRwin       0
SlowStart            0
CongAvoid            0
CongestionSignals    2
OtherReductions      19402
X_OtherReductionsCV  0
X_OtherReductionsCM  19402
CongestionOverCount  13
CurCwnd              4344
MaxCwnd              102808
CurSsthresh          94894680
LimCwnd              4294965848
MaxSsthresh          94894680
MinSsthresh          7240
FastRetran           2
Timeouts             0
SubsequentTimeouts   0
CurTimeoutCount      0
AbruptTimeouts       0
PktsRetrans          7
BytesRetrans         10136
DupAcksIn            41940
SACKsRcvd            118692
SACKBlocksRcvd       189919
PreCongSumCwnd       91224
PreCongSumRTT        6
PostCongSumRTT       7
PostCongCountRTT     2
ECERcvd              0
SendStall            0
QuenchRcvd           0
RetranThresh         30
NonRecovDA           0
AckAfterFR           0
DSACKDups            0
SampleRTT            3
SmoothedRTT          3
RTTVar               50
MaxRTT               4
MinRTT               2
SumRTT               142655
CountRTT             43932
CurRTO               203
MaxRTO               204
MinRTO               203
CurMSS               1448
MaxMSS               1448
MinMSS               524
X_Sndbuf             206976
X_Rcvbuf             87380
CurRetxQueue         0
MaxRetxQueue         0
CurAppWQueue         130320
MaxAppWQueue         237472
CurRwinSent          5888
MaxRwinSent          5888
MinRwinSent          5840
LimRwin              0
DupAcksOut           0
CurReasmQueue        0
MaxReasmQueue        0
CurAppRQueue         0
MaxAppRQueue         0
X_rcv_ssthresh       5840
X_wnd_clamp          64087
X_dbg1               5888
X_dbg2               536
X_dbg3               5840
X_dbg4               0
CurRwinRcvd          3137536
MaxRwinRcvd          3137536
MinRwinRcvd          17896
LocalAddressType     1
LocalAddress         198.2.1.2
LocalPort            56648
RemAddress           131.225.2.16
RemPort              5001
X_RcvRTT             0
[root@gw004 ipv4]#

..................................................................

WIth SACK Off:

Throughput: 258Mbps

Connection 5 (198.2.1.2 43578  131.225.2.16 5001)
State                1
SACKEnabled          0
TimestampsEnabled    1
NagleEnabled         1
ECNEnabled           0
SndWinScale          11
RcvWinScale          7
ActiveOpen           1
MSSRcvd              0
WinScaleRcvd         11
WinScaleSent         7
PktsOut              223011
DataPktsOut          223011
DataBytesOut         326318584
PktsIn               216404
DataPktsIn           0
DataBytesIn          0
SndUna               4002973902
SndNxt               4002973902
SndMax               4002973902
ThruBytesAcked       322904090
SndISS               3680069812
RcvNxt               2942495629
ThruBytesReceived    0
RecvISS              2942495629
StartTimeSec         1208277475
StartTimeUsec        779859
Duration             18149747
SndLimTransSender    4
SndLimBytesSender    10456
SndLimTimeSender     3787
SndLimTransCwnd      3
SndLimBytesCwnd      326308128
SndLimTimeCwnd       10006059
SndLimTransRwin      0
SndLimBytesRwin      0
SndLimTimeRwin       0
SlowStart            0
CongAvoid            0
CongestionSignals    3
OtherReductions      13166
X_OtherReductionsCV  0
X_OtherReductionsCM  13166
CongestionOverCount  37
CurCwnd              10136
MaxCwnd              173760
CurSsthresh          94894680
LimCwnd              4294965848
MaxSsthresh          94894680
MinSsthresh          46336
FastRetran           3
Timeouts             0
SubsequentTimeouts   0
CurTimeoutCount      0
AbruptTimeouts       0
PktsRetrans          7
BytesRetrans         10136
DupAcksIn            59484
SACKsRcvd            0
SACKBlocksRcvd       0
PreCongSumCwnd       286704
PreCongSumRTT        12
PostCongSumRTT       11
PostCongCountRTT     3
ECERcvd              0
SendStall            0
QuenchRcvd           0
RetranThresh         23
NonRecovDA           0
AckAfterFR           0
DSACKDups            0
SampleRTT            4
SmoothedRTT          4
RTTVar               50
MaxRTT               6
MinRTT               2
SumRTT               159332
CountRTT             48291
CurRTO               204
MaxRTO               204
MinRTO               203
CurMSS               1448
MaxMSS               1448
MinMSS               524
X_Sndbuf             451584
X_Rcvbuf             87380
CurRetxQueue         0
MaxRetxQueue         0
CurAppWQueue         373584
MaxAppWQueue         454672
CurRwinSent          5888
MaxRwinSent          5888
MinRwinSent          5840
LimRwin              0
DupAcksOut           0
CurReasmQueue        0
MaxReasmQueue        0
CurAppRQueue         0
MaxAppRQueue         0
X_rcv_ssthresh       5840
X_wnd_clamp          64087
X_dbg1               5888
X_dbg2               536
X_dbg3               5840
X_dbg4               0
CurRwinRcvd          3137536
MaxRwinRcvd          3137536
MinRwinRcvd          17896
LocalAddressType     1
LocalAddress         198.2.1.2
LocalPort            43578
RemAddress           131.225.2.16
RemPort              5001
X_RcvRTT             0
[root@gw004 ipv4]#


