From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-09-25
Date: Tue, 25 Sep 2012 18:01:19 +0200
Message-ID: <20120925160119.GA31069@ritirata.org>
References: <1348588637-18441-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1348588637-18441-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

Hello David,

here are some instructions to solve the conflict you will hit while merging net
with net-next.

Thank you,
	Antonio




++<<<<<<< HEAD
++=======
+ 	int if_num;
++>>>>>>> 7caf69f... batman-adv: Fix symmetry check / route flapping in multi interface setups


resolves to:
========
	int if_num;
>>>>>>>>




++<<<<<<< HEAD
 +		sum_orig = orig_node_tmp->bcast_own_sum[if_incoming->if_num];
++=======
+ 		if_num = router->if_incoming->if_num;
+ 		sum_orig = orig_node_tmp->bcast_own_sum[if_num];
++>>>>>>> 7caf69f... batman-adv: Fix symmetry check / route flapping in multi interface setups

resolves to:
=======
		if_num = router->if_incoming->if_num;
		sum_orig = orig_node_tmp->bcast_own_sum[if_num];
>>>>>>>





++<<<<<<< HEAD
 +		sum_neigh = orig_node_tmp->bcast_own_sum[if_incoming->if_num];
++=======
+ 		if_num = neigh_node->if_incoming->if_num;
+ 		sum_neigh = orig_node_tmp->bcast_own_sum[if_num];
++>>>>>>> 7caf69f... batman-adv: Fix symmetry check / route flapping in multi interface setups

resolves to:
=======
		if_num = neigh_node->if_incoming->if_num;
		sum_neigh = orig_node_tmp->bcast_own_sum[if_num];
>>>>>>
