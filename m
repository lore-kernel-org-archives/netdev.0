From: Julian Anastasov <ja@ssi.bg>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 02:24:36 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0204110213230.15041-100000@u.domain.uli>
References: <15540.50303.858294.986710@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <15540.50303.858294.986710@robur.slu.se>
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 11 Apr 2002, Robert Olsson wrote:

>  If we limit us to "static routes" for the other routes we must definitely leave to 
>  some with routing/topologi knowledge and we must not break systems with "routing 
>  daemons".

	include/linux/rtnetlink.h already contains the needed RTPROT_xxx
definitions. The most used daemons don't use RTPROT_STATIC. The kernel
does not know that the daemon registers static routes, they all
have its own RTPROT_value. The static routes are marked as such only
in the daemon's config file. May be it is possible value RTPROT_STATIC
to be marked in comments as a kernel property.

Regards

--
Julian Anastasov <ja@ssi.bg>
