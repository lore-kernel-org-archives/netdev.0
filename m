From: Wenji Wu <wenji@fnal.gov>
Subject: about Linux adaptivly adjusting dupthresh
Date: Thu, 28 Aug 2008 09:20:15 -0500
Message-ID: <001101c90919$313d67b0$a05ee183@D2GT6T71>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net>
 <000001c90852$a1c19a50$a05ee183@D2GT6T71>
 <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
 <fb62ce3717a7.48b5b0a8@fnal.gov>
 <Pine.LNX.4.64.0808280928450.5170@wrl-59.cs.helsinki.fi>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'David Miller' <davem@davemloft.net>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:45805 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbYH1Ohl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 10:37:41 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0K6B00G49DTEVG@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Thu, 28 Aug 2008 09:20:20 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008082809202030851 for
 <netdev@vger.kernel.org>; Thu, 28 Aug 2008 09:20:20 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0K6B00201EBAW2@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Thu, 28 Aug 2008 09:20:20 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0808280928450.5170@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, I made a mistake in the last post, what I mean is "algorithms
adaptively adjust TCP reordering threshold dupthresh". 

I understand that "Eifel algorithm" or "DSACK TCP" will adaptively adjust
dupthresh to deal with packet reordering. Are there any other
reordering-tolerant algorithms implemented in Linux? 

Thanks,

wenji


