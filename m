From: jamal <hadi@cyberus.ca>
Subject: Re: patch: tc action cleanups
Date: 16 Jan 2005 13:41:53 -0500
Message-ID: <1105900913.1090.803.camel@jzny.localdomain>
References: <1105899636.1090.794.camel@jzny.localdomain>
	 <41EAB296.3090504@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EAB296.3090504@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 13:29, Patrick McHardy wrote:
> jamal wrote:
> 
> >Heres one i think you didnt resurect Patrick. If ok, Dave please apply.
> >Other than that i cant seem to find anything at issue with the core
> >(havent looked at the individual actions other than to follow changed
> >code from the core).
> >
> bindcnt/refcnt changes are protected by the rtnl, no need for extra locking.
> The lock only needs to protect data shared with the "act" function.

Very clever ;-> maybe add a comment then to that effect in your next
batch? Dave ignore that patch.

cheers,
jamal
