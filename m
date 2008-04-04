From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: RE: A Linux TCP SACK Question
Date: Sat, 5 Apr 2008 00:33:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46535 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbYDDVdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 17:33:04 -0400
In-Reply-To: <000b01c89699$00e99590$c95ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2008, Wenji Wu wrote:

> 
> >I'd suggest that you don't waste too much effort for 2.6.24. ...Most of it 
> >is recoded/updated since then.
> 
> I just tried it on 2.6.25-rc8. The result is still the same: the throughput
> with SACK on is less than with SACK off.

Hmm, can you also try if playing around with FRTO setting makes some 
difference (tcp_frto sysctl)?

-- 
 i.
