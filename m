From: Wenji Wu <wenji@fnal.gov>
Subject: RE: A Linux TCP SACK Question
Date: Fri, 04 Apr 2008 17:14:02 -0500
Message-ID: <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:39512 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbYDDWRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 18:17:51 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYT00FMVMRD28@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Fri, 04 Apr 2008 17:14:09 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040417140910834 for
 <netdev@vger.kernel.org>; Fri, 04 Apr 2008 17:14:09 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYT00D01N2TO6@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Fri, 04 Apr 2008 17:14:09 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>...Assuming it wasn't disabled already. If you find that there's 
>significant difference, you could try also with SACK+basic FRTO (set 
>the tcp_frto sysctl to 1).

No, still the same. I tried tcp_frto with 0, 1, 2. 

SACK On is worse than SACK off.

wenji


