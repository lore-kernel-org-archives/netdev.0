From: jamal <hadi@cyberus.ca>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: 28 Dec 2004 08:45:20 -0500
Message-ID: <1104241519.1089.79.camel@jzny.localdomain>
References: <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com>
	 <20041221123727.GA13606@electric-eye.fr.zoreil.com>
	 <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com>
	 <20041221204853.GA20869@electric-eye.fr.zoreil.com>
	 <20041221212737.GK5974@waste.org>
	 <20041221225831.GA20910@electric-eye.fr.zoreil.com>
	 <41C93FAB.9090708@trash.net> <41C9525F.4070805@trash.net>
	 <20041222123940.GA4241@electric-eye.fr.zoreil.com>
	 <41C98B75.9020802@trash.net>  <20041222171836.GL5974@waste.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Francois Romieu <romieu@fr.zoreil.com>,
        Mark Broadbent <markb@wetlettuce.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041222171836.GL5974@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-22 at 12:18, Matt Mackall wrote:
> On Wed, Dec 22, 2004 at 03:57:57PM +0100, Patrick McHardy wrote:
> > >Of course the patch is completely ugly and violates any layering
> > >principle one could think of. It was not submitted for inclusion :o)
> > 
> > Sure, but I think we should have a short-term workaround until
> > a better solution has been invented. Maybe dropping the packets
> > would be best for now, it only affects printks issued in paths
> > starting at qdisc_restart (-> hard_start_xmit -> ...). Queueing
> > the packets might also cause reordering since not all packets
> > are queued.
> 
> When I mentioned queueing, I was thinking of a netpoll-private queue
> that would be hooked to a softirq or some such so that it would be
> pushed out as soon as possible. Dropping may be the better approach 

I think so - just junk those packets. 

cheers,
jamal
