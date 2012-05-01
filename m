From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-05-01
Date: Tue, 01 May 2012 09:53:08 -0400 (EDT)
Message-ID: <20120501.095308.1750249183824872989.davem@davemloft.net>
References: <1335859266-7546-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1335859266-7546-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Tue,  1 May 2012 10:00:59 +0200

> this is the new version of my previous pull request (issued on 2012-04-29).
> I'd like to see this changesin net-next/linux-3.5.
> 
> In this pull request I entirely removed the D.A.T. code, that as we were
> discussing in the previous thread, needs some rewriting to avoid directly
> dealing with the neigh table.
> 
> This patchset only contains fixes and cleanups.

When I pull this tree I start to get an enormous number of objects
sent over, way more than your pull request indicates:

[davem@bql net-next]$ git pull git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem
remote: Counting objects: 42485, done.        
remote: Compressing objects: 100% (7640/7640), done.        
Receiving objects:  12% (4594/36644), 1.42 MiB | 56 KiB/s     C-c C-c

I Ctrl-C'd this because I don't even want to see what this is going to crap
into my tree.

You have something totally inappropriate in there, and I think your changes
are not based upon my net-next tree, but rather something entirely else.

I took a quick look and it looks like you prepared this against either
Linus's tree or the 'net' tree.

NEVER DO THIS.

You must based your changes exactly, and solely, upon the tree you
want me to pull your stuff it into.  It is never appropriate to make
changes against another tree, and then ask me to pull the result of
that into mine.

Please do not waste my time with garbage like this.
