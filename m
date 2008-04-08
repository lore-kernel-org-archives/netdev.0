From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 8 Apr 2008 20:26:36 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804082024410.23237@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71> <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov> <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov> <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov> <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
 <fbd3c4827acd.47fb4882@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41542 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbYDHR0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 13:26:39 -0400
In-Reply-To: <fbd3c4827acd.47fb4882@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Apr 2008, Wenji Wu wrote:

>  
> > It's a bit hard for me to believe, considering what the last weeks 
> > debug 
> > has revealed about internals of it. Have you checked it from the dumps 
> > or 
> > from the overall results, a similarity in the latter could be due to 
> > other factors related to the differences in reordering detection 
> > between 
> > NewReno/SACK.
> > 
>
> Get back to you later, and post the tcpdump file for 2.6.25. 

Please, if possible use a kernel version where my today applied tcp fixes 
are in, ie., at least DaveM's net-2.6 already has them, I didn't check if 
Linus has pulled them in yet.

-- 
 i.
