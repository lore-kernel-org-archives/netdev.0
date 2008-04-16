From: Wenji Wu <wenji@fnal.gov>
Subject: RE: RE: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 09:46:04 -0500
Message-ID: <000101c89fd0$98bbfd50$6b5ee183@D2GT6T71>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
 <000301c89e81$80124570$6b5ee183@D2GT6T71>
 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
 <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
 <fc3c25e72104.4804a729@fnal.gov>
 <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>,
	'Netdev' <netdev@vger.kernel.org>
To: 'John Heffner' <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:46368 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211AbYDPOxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 10:53:38 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZF0098F9G761@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Wed, 16 Apr 2008 09:46:07 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041609460713845 for
 <netdev@vger.kernel.org>; Wed, 16 Apr 2008 09:46:07 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZF00801AABKZ@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Wed, 16 Apr 2008 09:46:07 -0500 (CDT)
In-reply-to: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Wenji, can you try this out?  Patch against net-2.6.26.

I just try with the new patch. It works, saturating the 1Gbps link.

The experiment works as:

      Sender --- Router --- Receiver

Iperf is sending from the sender to the receiver. In between there is an
emulated router which runs netem. The emulated router has two interfaces,
both with netem configured.  One interface emulates the forward path and the
other for the reverse path. Both netem interfaces are configured with 1.5ms
delay and 0.15ms variance. No packet drops. Kernel 2.6.25-rc9 patched with
the file you provided

Thanks,

wenji


