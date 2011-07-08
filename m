From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-07-08
Date: Fri, 08 Jul 2011 08:46:42 -0700 (PDT)
Message-ID: <20110708.084642.1953457077503391470.davem@davemloft.net>
References: <1310078023-28958-1-git-send-email-lindner_marek@yahoo.de>
	<201107080039.05143.lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: lindner_marek-LWAfsSFWpa4@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201107080039.05143.lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Date: Fri, 8 Jul 2011 00:39:04 +0200

> The following changes since commit 44c4349a2a117b22a5c4087f2ac9faf10c575e17:
> 
>   batman-adv: Replace version info instead of appending them (2011-07-05 14:48:56 +0200)
> 
> are available in the git repository at:
>   git://git.open-mesh.org/linux-merge.git batman-adv/next
> 
> Antonio Quartulli (4):
>       batman-adv: initialise last_ttvn and tt_crc for the orig_node structure
>       batman-adv: keep local table consistency for further TT_RESPONSE
>       batman-adv: keep global table consistency in case of roaming
>       batman-adv: request the full table if tt_crc doesn't match

Pulled.

You may want to make the tt_response_fill_table() callback return
'bool' if it's just returning what amounts to true/false values.
