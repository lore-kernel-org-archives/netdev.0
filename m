From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: tc action cleanups
Date: Sun, 16 Jan 2005 19:29:42 +0100
Message-ID: <41EAB296.3090504@trash.net>
References: <1105899636.1090.794.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1105899636.1090.794.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>Heres one i think you didnt resurect Patrick. If ok, Dave please apply.
>Other than that i cant seem to find anything at issue with the core
>(havent looked at the individual actions other than to follow changed
>code from the core).
>
bindcnt/refcnt changes are protected by the rtnl, no need for extra locking.
The lock only needs to protect data shared with the "act" function.

>Very well done.
>
A couple additional fixes are coming up later tonight.

Regards
Patrick
