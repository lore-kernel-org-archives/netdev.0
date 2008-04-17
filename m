From: Anton Titov <a.titov@host.bg>
Subject: Re: Bad network performance over 2Gbps
Date: Thu, 17 Apr 2008 13:02:30 +0300
Message-ID: <1208426550.6049.10.camel@localhost>
References: <1208282804.23631.27.camel@localhost>
	 <175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com>
	 <48051173.5030802@intel.com>  <48051734.1000107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter2.host.bg ([87.120.40.156]:54229 "EHLO filter2.host.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762054AbYDQKLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 06:11:00 -0400
In-Reply-To: <48051734.1000107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-15 at 16:59 -0400, Chris Snook wrote:
> Still, I think you're on to something here.  Disabling NAPI and instead 
> tuning the cards' interrupt coalescing settings might allow irqbalance 
> to do a better job than it is currently.

Disabling NAPI allowed me to push as much as 3.5Gbit out of the same
server with ~ 20% of time CPUs doing software interrupts.

Regards,
Anton Titov

