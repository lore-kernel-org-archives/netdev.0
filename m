From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: 11 Jul 2003 08:20:00 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057900800.3588.50.camel@hades>
References: <Pine.LNX.4.44.0307110750150.24705-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andre Tomt <andre@tomt.net>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0307110750150.24705-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-07-11 at 07:51, Pekka Savola wrote:
> Well, the system may make some sense, but IMHO, there is still zero sense 
> in policing this thing when you add a route.  That's just plain bogus.  
> This is a bug which must be fixed ASAP.

Correct me if I'm wrong but I think in this case the interface had
forwarding enabled and the sanity check in fact prevented a default
route pointing to the node itself from being configured.

Otherwise I fully agree. The subnet router anycast address doesn't
warrant any special handling.

	MikaL
