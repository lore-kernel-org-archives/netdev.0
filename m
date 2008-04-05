From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: RE: A Linux TCP SACK Question
Date: Sat, 5 Apr 2008 20:42:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804052041480.8668@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45460 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbYDERmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 13:42:22 -0400
In-Reply-To: <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2008, Wenji Wu wrote:

> 
> >...Assuming it wasn't disabled already. If you find that there's 
> >significant difference, you could try also with SACK+basic FRTO (set 
> >the tcp_frto sysctl to 1).
> 
> No, still the same. I tried tcp_frto with 0, 1, 2. 
> 
> SACK On is worse than SACK off.

No easy solution then, we'll have to take a look on tcpdumps.

-- 
 i.
