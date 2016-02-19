From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request [net]: batman-adv 20160216
Date: Fri, 19 Feb 2016 15:37:18 -0500 (EST)
Message-ID: <20160219.153718.442738962662787470.davem@davemloft.net>
References: <1455634888-29400-1-git-send-email-a@unstable.cc>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: a@unstable.cc
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1455634888-29400-1-git-send-email-a-2CpIooy/SPIKlTDg6p0iyA@public.gmane.org>
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

From: Antonio Quartulli <a@unstable.cc>
Date: Tue, 16 Feb 2016 23:01:25 +0800

> this pull request is intended for net.
> 
> Two of the fixes included in this patchset prevent a wrong memory
> access - it was triggered when removing an object from a list
> after it was already free'd due to bad reference counting.
> This misbehaviour existed for both the gw_node and the
> orig_node_vlan object and has been fixed by Sven Eckelmann.
> 
> The last patch fixes our interface feasibility check and prevents
> it from looping indefinitely when two net_device objects
> reference each other via iflink index (i.e. veth pair), by
> Andrew Lunn

Pulled, thanks Antonio.

And thanks for the heads up about the potential merge issues, I'll watch
for that.
