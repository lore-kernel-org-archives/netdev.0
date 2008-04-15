From: Wenji Wu <wenji@fnal.gov>
Subject: RE: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 12:55:24 -0500
Message-ID: <001b01c89f21$e41ecca0$6b5ee183@D2GT6T71>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
 <000301c89e81$80124570$6b5ee183@D2GT6T71>
 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
 <fcb2d79550b4.480493e2@fnal.gov>
 <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>,
	'Netdev' <netdev@vger.kernel.org>
To: 'John Heffner' <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:40415 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbYDOSDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 14:03:21 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZD00F3LNP35B@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Tue, 15 Apr 2008 12:55:34 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041512553307959 for
 <netdev@vger.kernel.org>; Tue, 15 Apr 2008 12:55:33 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZD00101OE8D0@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 15 Apr 2008 12:55:33 -0500 (CDT)
In-reply-to: <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>We can see that in both cases you are getting throttled by
>tcp_moderate_cwnd (X_OtherReductionsCM).  I'm not sure offhand why
>it's reaching this code - I would have thought that the high
>tp->reordering would prevent this.  Ilpo, do you have any insights?

>It's not all that surprising that packets_in_flight is a higher value
>with newreno than sack, which would explain the higher window with
>newreno.

>Wenji, the web100 kernel has a sysctl - WAD_MaxBurst.  I suspect it
>may make a significant difference if you set this to a large value.

It is surprising! When I increase WAD_MaxBurst (Patched with Web100) from 3
to 20, the throughput in both cases (SACK ON/OFF) will saturate the 1Gbps
Link!!!


