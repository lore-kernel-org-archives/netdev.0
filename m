From: "erik.hugne@ericsson.com" <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 1/8] tipc: decrease connection flow control
 window
Date: Fri, 9 May 2014 16:27:39 +0200
Message-ID: <20140509142739.GQ30044@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
 <1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71067C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: 'Jon Maloy' <jon.maloy@ericsson.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"maloy@donjonn.com" <maloy@donjonn.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:56844 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbaEIO1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 10:27:42 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F71067C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 09, 2014 at 01:30:43PM +0000, David Laight wrote:
> Sounds a bit like a badly designed protocol to me...

Well, i don't like this either but the current message-oriented flowcontrol
will eventually be replaced with a byte-based one. Right now we're trying
to find a way to adapt a message-oriented flow control to per-socket buffer
constraints, without breaking protocol compatibility.

//E
