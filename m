From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/9] batman-adv: add UNICAST_4ADDR packet
 type
Date: Sun, 04 Nov 2012 12:30:57 -0500 (EST)
Message-ID: <20121104.123057.59138392933877977.davem@davemloft.net>
References: <20121103.152226.244759041688205348.davem@davemloft.net>
 <12758662.vFhVQet4vg@sven-laptop.home.narfation.org>
 <5244128.ID77evUSAJ@sven-laptop.home.narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5244128.ID77evUSAJ-S/pmIDWWJIwhrEaHGRlFQnOel7F/LzPIcbWoRP8EXgk@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Date: Sun, 04 Nov 2012 12:20:13 +0100

> To push this question in a direction: May I assume that the driver always 
> ensures that the ethernet header is 4 byte boundary - NET_IP_ALIGN (2) 
> aligned?

Yes.

> When yes, this would result in a slight variations of your suggestion: 
> unicast/bcast headers have to end at 4 bytes boundary + 2 bytes. The reason is 
> easy to explain. batman-adv unicast/bcast headers are used to encapsulate the 
> important parts of an ethernet frame:
> 
> Ethernet Header for P2P | batman-adv header stuff | ethernet header | payload.
> 
> Would you aggree?

Then you can get rid of the packed crap.
