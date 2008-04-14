From: Wenji Wu <wenji@fnal.gov>
Subject: RE: A Linux TCP SACK Question
Date: Mon, 14 Apr 2008 11:10:06 -0500
Message-ID: <000001c89e4a$019f1330$6b5ee183@D2GT6T71>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov>
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:38853 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873AbYDNQRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 12:17:00 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZB00GVFOJ9D4@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Mon, 14 Apr 2008 11:10:12 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041411101221278 for
 <netdev@vger.kernel.org>; Mon, 14 Apr 2008 11:10:12 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZB00501OUHEY@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Mon, 14 Apr 2008 11:10:12 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Ilop,

The latest results have been posted to:

https://plone3.fnal.gov/P0/WAN/Members/wenji/tcp_dump_files_sack/

The kernel under test is: Linux-2.6.25-rc9. I have checked with its
changelog, which shows that your latest fix is included.

In the tests, I vary the tcp_frto (0, 1, and 2) with SACK On/Off.

The experiment works as:

      Sender --- Router --- Receiver

Iperf is sending from the sender to the receiver. In between there is an
emulated router which runs netem. The emulated router has two interfaces,
both with netem configured.  One interface emulates the forward path and the
other for the reverse path. Both netem interfaces are configured with 1.5ms
delay and 0.15ms variance. No packet drops in tests and packet capturing.

All of these systems are multi-core platforms, with 2G+ CPU. I run
TOP to verify, CPUs are idle most of time.

wenji


