From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-09-08
Date: Thu, 22 Sep 2011 13:05:09 +0200
Message-ID: <201109221305.10111.lindner_marek@yahoo.de>
References: <201109220139.26897.lindner_marek@yahoo.de>
	<201109220210.05025.lindner_marek@yahoo.de>
	<20110921.201153.1030355996800820632.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20110921.201153.1030355996800820632.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Thursday, September 22, 2011 02:11:53 David Miller wrote:
> From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
> Date: Thu, 22 Sep 2011 02:10:04 +0200
> 
> > No, the data structures for the routing lookups remain the same but there
> > will be more than one way to fill them with data. You will only use one
> > "filling algorithm" at a time, so you will need to select the one you
> > want.
> 
> Extend the userspace interface for adding route entries with a boolean
> flag.  You're using netlink right?  If so, this should be trivial by
> simply adding a flags attribute if you don't have one already.

Not really. It's rather the tcp westwood vs tcp reno type of story. But I 
think we simply make this a runtime option to keep everybody happy.

Thanks,
Marek
