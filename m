From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Fri, 08 Aug 2008 20:30:49 -0700
Message-ID: <489D0F69.9050307@zytor.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <489C97FB.2030408@zytor.com> <20080809014925.GA26529@gondor.apana.org.au> <200808090443.00597.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@zeniv.linux.org.uk,
	vegard.nossum@gmail.com
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:33423 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbYHIDh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 23:37:29 -0400
In-Reply-To: <200808090443.00597.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Walter wrote:
> 
> These FPU changes are already in 2.6.26. Undoing them, would that be accepted 
> for 2.6.26 stable?
> 
> Maybe the following solution would be possible: if a processor with padlock is 
> detected the memory for xstate is always allocated when the thread is created 
> instead "lazy"?
> 

That will effectively happen, so it doesn't really matter.

The true optimization would be to recognize that the state doesn't have 
to be saved, and track when we did so, and so on and so forth.

VIA really did their customers a disservice tying this to CR0.TS.

	-hpa
