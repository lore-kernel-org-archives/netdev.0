From: "David S. Miller" <davem@davemloft.net>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 11:20:25 -0800
Message-ID: <20041217112025.27688eb6.davem@davemloft.net>
References: <41912F7A.6000408@redhat.com>
	<200412161153.51251.hasso@estpak.ee>
	<Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
	<200412161302.42357.hasso@estpak.ee>
	<41C2F6E5.5010607@cs.columbia.edu>
	<Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
	<41C30212.6000906@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hno@marasystems.com, hasso@estpak.ee, laforge@gnumonks.org,
        nhorman@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea G Forte <andreaf@cs.columbia.edu>
In-Reply-To: <41C30212.6000906@cs.columbia.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004 10:58:10 -0500
Andrea G Forte <andreaf@cs.columbia.edu> wrote:

> This does not help, since if I want to use my secondary IP address 
> instead of my primary, I cannot delete the primary otherwise all of my 
> secondary IPs are lost as well (and since I can only have only one 
> primary IP address).

By definition, a secondary IP address on an interface is not to
be used as a source.   It is the whole reason for the distinction
between primary and secondary IP addresses, and it is why all secondaries
are deleted once the primary is removed (because there are no valid
source addresses to choose from any longer, therefore IP valid
communications are no longer possible).
