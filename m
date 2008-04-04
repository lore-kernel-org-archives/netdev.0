From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Fri, 04 Apr 2008 15:07:17 -0500
Message-ID: <fb9cfa9c317b.47f64425@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:41115 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511AbYDDUUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 16:20:19 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYT0060BGSIU7@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Fri, 04 Apr 2008 15:07:17 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040415071700748 for
 <netdev@vger.kernel.org>; Fri, 04 Apr 2008 15:07:17 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYT00401GZ3EP@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Fri, 04 Apr 2008 15:07:17 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Fri, 4 Apr 2008, Wenji Wu wrote:
> 
> > Every system runs Linux 2.6.24.
> 
> You should have reported kernel version right from the beginning. It 
> may 
> have a huge effect... ;-)
> 
> > When sack is on, the throughput is around 180Mbps
> > When sack is off, the throughput is around 260Mbps
> 
> Not a surprise, once some reordering is detected, SACK TCP switches 
> away 
> from FACK to something that's not what you'd expect (in 2.6.24), you 
> should try 2.6.25-rcs first in which the non-FACK is very close to 
> RFC3517.
> 
> > I was thinking that if the reordered ACKs/SACKs cause cjavascript:parent.send('smtp')
Send Message
Sendonfusion in the
> > sender, and sender will unnecessarily reduce either the CWND or the
> > TCP_REORDERING threshold. I might need to take a serious look at the 
> 
> > SACK implementation. 
> 
> I'd suggest that you don't waste too much effort for 2.6.24. ...Most 
> of it 
> is recoded/updated since then.

Thanks, i would try it on the latest version and report the results.

wenji

