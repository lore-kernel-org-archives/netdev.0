From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: Re: ip address delete bug?
Date: Tue, 4 Oct 2005 21:23:27 +0000 (UTC)
Message-ID: <Pine.NEB.4.62.0510042118190.24353@ukato.freeshell.org>
References: <200593200127124@mail.routehat.org> <4342D3F9.80705@gmx.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2005@gmx.net>
In-Reply-To: <4342D3F9.80705@gmx.net>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Tue, 4 Oct 2005, Carl-Daniel Hailfinger wrote:

> OK, I found out that this is documented behaviour, although the hint is not 
> in the man page.

If it's not in the man page, then where is the below quote from?

> "secondary --- this address is not used when selecting the default source 
> address for outgoing packets. An IP address becomes secondary if another 
> address within the same prefix (network) already exists. The first address 
> within the prefix is primary and is the tag address for the group of all the 
> secondary addresses. When the primary address is deleted all of the 
> secondaries are purged too."
>
> That means there is no way to change the IP of an interface if the prefix and 
> network size stay the same. Are there any plans to fix that?

What's wrong with delete followed by add?

This thread started on netdev, so I'm cc-ing that, in case someone doesn't 
read both lists.

 			Alexey
