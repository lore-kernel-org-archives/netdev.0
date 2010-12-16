From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv8] net: Add batman-adv meshing protocol
Date: Thu, 16 Dec 2010 14:27:25 -0800 (PST)
Message-ID: <20101216.142725.212679030.davem@davemloft.net>
References: <1292275168-19882-1-git-send-email-sven@narfation.org>
	<20101216.140153.232733922.davem@davemloft.net>
	<20101216222111.GA13395@kroah.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20101216222111.GA13395-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
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

From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Date: Thu, 16 Dec 2010 14:21:11 -0800

> On Thu, Dec 16, 2010 at 02:01:53PM -0800, David Miller wrote:
>> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
>> Date: Mon, 13 Dec 2010 22:19:28 +0100
>> 
>> > B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
>> > protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
>> > wireless. See http://www.open-mesh.org/ for more information and user space
>> > tools.
>> > 
>> > Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
>> 
>> Applied, thanks Sven.
>> 
>> How do you want to take care of the copy that still lives under
>> staging?
>> 
>> Greg, any preferences on your end?
>> 
>> I'm more than happy to do the removal from my net-next-2.6 tree
>> since the bonafide copy of net/batman-adv is now there.
> 
> That might conflict with the patches that I have added to my tree for
> merging in the .38 timeframe for the batman code.  How about I just drop
> the whole drivers/staging/batman/ directory in my tree and then we don't
> have any merge issues?

Perfect.
