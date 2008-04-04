From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: RE: A Linux TCP SACK Question
Date: Fri, 4 Apr 2008 23:00:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45543 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750AbYDDUAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 16:00:54 -0400
In-Reply-To: <000001c8967c$496efa20$c95ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Apr 2008, Wenji Wu wrote:

> Every system runs Linux 2.6.24.

You should have reported kernel version right from the beginning. It may 
have a huge effect... ;-)

> When sack is on, the throughput is around 180Mbps
> When sack is off, the throughput is around 260Mbps

Not a surprise, once some reordering is detected, SACK TCP switches away 
from FACK to something that's not what you'd expect (in 2.6.24), you 
should try 2.6.25-rcs first in which the non-FACK is very close to 
RFC3517.

> I was thinking that if the reordered ACKs/SACKs cause confusion in the
> sender, and sender will unnecessarily reduce either the CWND or the
> TCP_REORDERING threshold. I might need to take a serious look at the 
> SACK implementation. 

I'd suggest that you don't waste too much effort for 2.6.24. ...Most of it 
is recoded/updated since then.


-- 
 i.
