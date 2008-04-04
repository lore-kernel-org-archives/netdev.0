From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Fri, 04 Apr 2008 16:40:52 -0500
Message-ID: <fbdee7bf38be.47f65a14@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:34735 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbYDDVuS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 17:50:18 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYT00DVKLBMDV@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Fri, 04 Apr 2008 16:40:53 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040416405308464 for
 <netdev@vger.kernel.org>; Fri, 04 Apr 2008 16:40:53 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYT00001LFGCD@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Fri, 04 Apr 2008 16:40:53 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Fri, 4 Apr 2008, Wenji Wu wrote:
> 
> > 
> > >I'd suggest that you don't waste too much effort for 2.6.24. 
> ...Most of it 
> > >is recoded/updated since then.
> > 
> > I just tried it on 2.6.25-rc8. The result is still the same: the throughput
> > with SACK on is less than with SACK off.
> 
> Hmm, can you also try if playing around with FRTO setting makes some 
> difference (tcp_frto sysctl)?

Still the same, I just tried with FRTO, FACK. No difference, SACK on is worse than SACK off.

wenji
