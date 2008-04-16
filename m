From: Wenji Wu <wenji@fnal.gov>
Subject: RE: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 09:50:19 -0500
Message-ID: <000201c89fd1$308edf30$6b5ee183@D2GT6T71>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: 'David Miller' <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:46368 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651AbYDPOxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 10:53:39 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZF0098F9G761@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Wed, 16 Apr 2008 09:50:22 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041609502214235 for
 <netdev@vger.kernel.org>; Wed, 16 Apr 2008 09:50:22 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZF00D01ADQYS@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Wed, 16 Apr 2008 09:50:22 -0500 (CDT)
In-reply-to: <20080416.023551.70464279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>Right, we can tweak this thing further later.

>*beep* *beep*

>I've added John's patch to net-2.6.26

I just tried with John's patch. It works, saturating the 1Gbps in my test. 

Without the patch, the throughput is around 180Mbps with SACK On, 250Mbps
with SACK off.

The same test environment described in my previous emails.

wenji


