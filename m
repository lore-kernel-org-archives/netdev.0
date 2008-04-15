From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 10:45:27 -0500
Message-ID: <fb71f1b5208d.48048747@fnal.gov>
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
Received: from mailgw2.fnal.gov ([131.225.111.12]:41471 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbYDOP6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 11:58:00 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZD00IULCDPHM@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Tue, 15 Apr 2008 10:45:27 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041510452626785 for
 <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:45:26 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZD00001IF1B5@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 15 Apr 2008 10:45:27 -0500 (CDT)
In-reply-to: <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sill the mystery remains as to why *both* are going so slowly.  You
> mentioned you're using a web100 kernel.  What are the final values of
> all the variables for the connections (grab with readall)?

Kernel 2.6.24, 

"echo 1 > /proc/sys/net/ipv4/tcp_no_metrics_save"

With SACK off:

Throughtpu 256Mbps

Connection 6 (198.2.1.2 38054  131.225.2.16 5001)
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
PktsOut              221715
DataPktsOut          221715
DataBytesOut         324429992
PktsIn               215245
DataPktsIn           0
DataBytesIn          0
SndUna               2784091744
SndNxt               2784091744
SndMax               2784091744
ThruBytesAcked       321011738
SndISS               2463080006
RcvNxt               1309516114
ThruBytesReceived    0
RecvISS              1309516114
StartTimeSec         1208273537
StartTimeUsec        293029
Duration             14594853
SndLimTransSender    6
SndLimBytesSender    23960
SndLimTimeSender     4137
SndLimTransCwnd      5
SndLimBytesCwnd      324406032
SndLimTimeCwnd       10046308
SndLimTransRwin      0
SndLimBytesRwin      0
SndLimTimeRwin       0
SlowStart            0
CongAvoid            0
CongestionSignals    4
OtherReductions      13167
X_OtherReductionsCV  0
X_OtherReductionsCM  13167
CongestionOverCount  54
CurCwnd              4344
MaxCwnd              173760
CurSsthresh          94894680
LimCwnd              4294965848
MaxSsthresh          94894680
MinSsthresh          4344
FastRetran           4
Timeouts             0
SubsequentTimeouts   0
CurTimeoutCount      0
AbruptTimeouts       0
PktsRetrans          17
BytesRetrans         24616
DupAcksIn            59556
SACKsRcvd            0
SACKBlocksRcvd       0
PreCongSumCwnd       375032
PreCongSumRTT        12
PostCongSumRTT       15
PostCongCountRTT     4
ECERcvd              0
SendStall            0
QuenchRcvd           0
RetranThresh         29
NonRecovDA           0
AckAfterFR           0
DSACKDups            0
SampleRTT            3
SmoothedRTT          3
RTTVar               50
MaxRTT               46
MinRTT               2
SumRTT               158191
CountRTT             47830
CurRTO               203
MaxRTO               237
MinRTO               203
CurMSS               1448
MaxMSS               1448
MinMSS               524
X_Sndbuf             1919232
X_Rcvbuf             87380
CurRetxQueue         0
MaxRetxQueue         0
CurAppWQueue         1786832
MaxAppWQueue         1886744
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
LocalPort            38054
RemAddress           131.225.2.16
RemPort              5001
X_RcvRTT             0
...............................................................

With SACK On

Throughput: 178Mbps

Connection 3 (131.225.2.22 22  131.225.82.152 52973)
State                5
SACKEnabled          3
TimestampsEnabled    1
NagleEnabled         0
ECNEnabled           0
SndWinScale          11
RcvWinScale          7
ActiveOpen           0
MSSRcvd              0
WinScaleRcvd         11
WinScaleSent         7
PktsOut              230
DataPktsOut          230
DataBytesOut         25783
PktsIn               353
DataPktsIn           164
DataBytesIn          11120
SndUna               2809669838
SndNxt               2809669838
SndMax               2809669838
ThruBytesAcked       18423
SndISS               2809651415
RcvNxt               2817947310
ThruBytesReceived    11120
RecvISS              2817936190
StartTimeSec         1208271915
StartTimeUsec        71844
Duration             2362591841
SndLimTransSender    6
SndLimBytesSender    25783
SndLimTimeSender     2273927770
SndLimTransCwnd      5
SndLimBytesCwnd      0
SndLimTimeCwnd       1047
SndLimTransRwin      0
SndLimBytesRwin      0
SndLimTimeRwin       0
SlowStart            0
CongAvoid            0
CongestionSignals    0
OtherReductions      0
X_OtherReductionsCV  0
X_OtherReductionsCM  0
CongestionOverCount  0
CurCwnd              5792
MaxCwnd              13032
CurSsthresh          4294966376
LimCwnd              4294965848
MaxSsthresh          0
MinSsthresh          4294967295
FastRetran           0
Timeouts             0
SubsequentTimeouts   0
CurTimeoutCount      0
AbruptTimeouts       0
PktsRetrans          0
BytesRetrans         0
DupAcksIn            0
SACKsRcvd            0
SACKBlocksRcvd       0
PreCongSumCwnd       0
PreCongSumRTT        0
PostCongSumRTT       0
PostCongCountRTT     0
ECERcvd              0
SendStall            0
QuenchRcvd           0
RetranThresh         3
NonRecovDA           0
AckAfterFR           0
DSACKDups            0
SampleRTT            0
SmoothedRTT          3
RTTVar               50
MaxRTT               40
MinRTT               0
SumRTT               1269
CountRTT             221
CurRTO               203
MaxRTO               234
MinRTO               201
CurMSS               1448
MaxMSS               1448
MinMSS               1428
X_Sndbuf             16384
X_Rcvbuf             87380
CurRetxQueue         0
MaxRetxQueue         0
CurAppWQueue         0
MaxAppWQueue         0
CurRwinSent          14208
MaxRwinSent          14208
MinRwinSent          5792
LimRwin              8365440
DupAcksOut           0
CurReasmQueue        0
MaxReasmQueue        0
CurAppRQueue         0
MaxAppRQueue         1152
X_rcv_ssthresh       14144
X_wnd_clamp          64087
X_dbg1               14208
X_dbg2               1152
X_dbg3               14144
X_dbg4               0
CurRwinRcvd          3749888
MaxRwinRcvd          3749888
MinRwinRcvd          3747840
LocalAddressType     1
LocalAddress         131.225.2.22
LocalPort            22
RemAddress           131.225.82.152
RemPort              52973
X_RcvRTT             405000
..................................................................

wenji




