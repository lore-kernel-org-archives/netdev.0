From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH v2 net-next 15/15] tipc: remove old ASCII netlink API
Date: Mon, 6 Oct 2014 13:37:14 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C2EB615@eusaamb103.ericsson.se>
References: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
	<1412261921-28510-16-git-send-email-richard.alpe@ericsson.com>
 <20141003.165038.2121547250200790300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>,
	Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:64638 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbaJFNhU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 09:37:20 -0400
In-Reply-To: <20141003.165038.2121547250200790300.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: October-03-14 7:51 PM
> To: Richard Alpe
> Cc: netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net
> Subject: Re: [PATCH v2 net-next 15/15] tipc: remove old ASCII netlink API
> 
> From: <richard.alpe@ericsson.com>
> Date: Thu, 2 Oct 2014 16:58:41 +0200
> 
> > From: Richard Alpe <richard.alpe@ericsson.com>
> >
> > The API has been deprecated along with its user-space tool
> > "tipc-config". Users shall use the new kernel netlink API already in
> > place along with the new user space tool "tipc" that's part of the
> > tipc-utils package.
> >
> > Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> > Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> > Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> > Acked-by: Ying Xue <ying.xue@windriver.com>
> 
> Sorry, no matter what your circumstances, you cannot just break binaries
> that might be out there.

I disagree.  We did of course consider this before we posted the patch.  
There is absolutely no reason to believe there are binaries "out there" 
using this API. It is intended for and used only by our own tool "tipc-config", 
and the half-baked documentation that exists about it is not even
correct. This is an TIPC-internal API/ABI, which has changed over the years,
and keeps changing.  To our best judgement there is no risk in removing the
old API.

However, we took great care to not break any scripts that might be using 
tipc-config. Therefore, we made this wrapper that provides the old 
tipc-config command API to existing users.

Regards
///jon
> 
> The rest of this patch series is fine, but I'm really not going to even entertain
> applying this one, sorry.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
