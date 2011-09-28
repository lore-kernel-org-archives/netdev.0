From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: Introducing open source MSTP daemon
Date: Wed, 28 Sep 2011 12:56:19 +0300
Message-ID: <201109281256.19713.vitas@nppfactor.kiev.ua>
References: <201109221727.33010.vitas@nppfactor.kiev.ua> <20110922163939.GB1012103@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	"Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:54325 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab1I1J6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 05:58:11 -0400
In-Reply-To: <20110922163939.GB1012103@jupiter.n2.diac24.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 September 2011 19:39:40 David Lamparter wrote:
>
> I assume it works with current Linux kernel bridge code on a RSTP level?
> The code looks considerably more maintainable than rstpd :) - I will try
> running it later!
>

Ok, now it works with kernel bridge code and you can evaluate it.

mstpd sends all the state changes in the CIST to the kernel bridge, so it 
works for the (R)STP cases as expected. Checked it by connecting two bridges: 
one running mstpd and another running rstpd and in-kernel stp. In both cases 
mstpd code behaves reasonably. Not checked in more complex setups though.

Also mstpd translates to the bridge code fdb flushing events and changes 
ageing time (for the rapid ageing case).

-- 
Vitalii Demianets
