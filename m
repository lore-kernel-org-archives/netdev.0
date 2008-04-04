From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: RE: A Linux TCP SACK Question
Date: Sat, 5 Apr 2008 00:39:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2053985785-1207345172=:8186"
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47388 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbYDDVjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 17:39:37 -0400
In-Reply-To: <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2053985785-1207345172=:8186
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 5 Apr 2008, Ilpo Järvinen wrote:

> On Fri, 4 Apr 2008, Wenji Wu wrote:
> 
> > 
> > >I'd suggest that you don't waste too much effort for 2.6.24. ...Most of it 
> > >is recoded/updated since then.
> > 
> > I just tried it on 2.6.25-rc8. The result is still the same: the throughput
> > with SACK on is less than with SACK off.
> 
> Hmm, can you also try if playing around with FRTO setting makes some 
> difference (tcp_frto sysctl)?

...Assuming it wasn't disabled already. If you find that there's 
significant difference, you could try also with SACK+basic FRTO (set 
the tcp_frto sysctl to 1).

-- 
 i.
---696208474-2053985785-1207345172=:8186--
