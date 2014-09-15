From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Mon, 15 Sep 2014 16:35:34 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C2C9AB0@eusaamb103.ericsson.se>
References: <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>
	<20140912.171038.1165432718811920305.davem@davemloft.net>
	<54169B6C.5060709@ericsson.com>
 <20140915.113846.1276168899072885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>,
	Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:56348 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbaIOQfg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:35:36 -0400
In-Reply-To: <20140915.113846.1276168899072885.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: September-15-14 11:39 AM
> To: Richard Alpe
> Cc: netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net
> Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
> 
> From: Richard Alpe <richard.alpe@ericsson.com>
> Date: Mon, 15 Sep 2014 09:55:24 +0200
> 
> > The amount of publications a socket can have is large (~65 000). Do
> > you still think this a viable solution?
> 
> Then maybe you want to have a completely separate netlink operation to
> dump the publications, the request would provide a key saying which
> socket's publications to dump.

A compromise could be to list a fix maximum number (100?) of publications
 that cover all "normal" cases, and return a hint indicating that there is
more if this was not enough. For 99% of the sockets this would be enough, 
and for the remaining ones the tool would have to use the second operation
to make the listing complete.

///jon

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
