From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] xfrm: avoid to send/receive the exceeding hard
 lifetime data
Date: Fri, 14 Dec 2012 12:39:45 +0100
Message-ID: <20121214113945.GH18940@secunet.com>
References: <1355387152-9963-1-git-send-email-roy.qing.li@gmail.com>
 <20121213101422.GF18940@secunet.com>
 <CAJFZqHyUSHS3-TjkGQ3WiD486MCCTbiRd4vXUAcbJ=ZqqsnQoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52769 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309Ab2LNLjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 06:39:48 -0500
Content-Disposition: inline
In-Reply-To: <CAJFZqHyUSHS3-TjkGQ3WiD486MCCTbiRd4vXUAcbJ=ZqqsnQoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 02:58:03PM +0800, RongQing Li wrote:
> 
> Yes, RFC does not say how to handle this packet.
> 
> But when I do a IPsec compliance test with IxANVL, the test case 5.3/5.11,
> which reports a error because it expects this packet should be dropped, but not.
> 
> 
> I do not know if it is bug, or if it is valuable to fix it?
> 

As long as the RFC does not state anything else, we ar ok in the
synchronous code path. But we need a fix for the asynchronous
code path.
