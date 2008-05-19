From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: IPV6_V6ONLY ignored for SCTP
Date: Tue, 20 May 2008 01:50:08 +0400
Message-ID: <20080519215008.GA21412@2ka.mipt.ru>
References: <alpine.LNX.1.10.0805181244480.15590@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55306 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbYESVuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 17:50:08 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0805181244480.15590@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, May 18, 2008 at 12:58:55PM +0200, Jan Engelhardt (jengelh@medozas.de) wrote:
> with the following short C program, I get "Address already in use"
> (when binding 'b'), but only when using IPPROTO_SCTP. When I use 
> IPPROTO_TCP for 'a' and 'b', everything is fine. Seems like SCTP
> is ignoring the V6ONLY flag.
> Running kernel is 2.6.25.3 on i686. Any other info needed?

SCTP does not honor not only v6only flag, but also bind to device.
Its association list check is rather simple and does not allow
simultaneous wildcard binding.

-- 
	Evgeniy Polyakov
