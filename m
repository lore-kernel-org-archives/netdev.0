From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] batman-adv: Fix mem leak in the
 batadv_tt_local_event() function
Date: Wed, 08 Aug 2012 16:04:28 -0700 (PDT)
Message-ID: <20120808.160428.2244694881256062176.davem@davemloft.net>
References: <alpine.LNX.2.00.1208072030500.3227@swampdragon.chaosbits.net>
 <20120807185036.GG3891@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org, jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org,
 lindner_marek-LWAfsSFWpa4@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20120807185036.GG3891-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Tue, 7 Aug 2012 20:50:36 +0200

> On Tue, Aug 07, 2012 at 08:32:34PM +0200, Jesper Juhl wrote:
>> Memory is allocated for 'tt_change_node' with kmalloc().
>> 'tt_change_node' may go out of scope really being used for anything
>> (except have a few members initialized) if we hit the 'del:' label.
>> This patch makes sure we free the memory in that case.
>> 
>> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
> 
> Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

Applied, thanks.
