From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 07/14] batman-adv: split neigh_new
 function into generic and batman iv specific parts
Date: Thu, 10 May 2012 12:07:28 -0400 (EDT)
Message-ID: <20120510.120728.1691568555429264215.davem@davemloft.net>
References: <1336561976-16088-8-git-send-email-ordex@autistici.org>
	<20120509.204111.1931607501484626500.davem@davemloft.net>
	<9033916.UuGU18BIPo@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <9033916.UuGU18BIPo@bentobox>
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

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Date: Thu, 10 May 2012 09:34:25 +0200

> On Wednesday, May 09, 2012 08:41:11 PM David Miller wrote:
> [...]
>> The namespace pollution of the batman-adv code needs to improve,
>> and I'm putting my foot down starting with this change.
>> 
>> If you have a static function which is therefore private to a
>> source file, name it whatever you want.
>> 
>> But once it gets exported out of that file, you have to give it
>> an appropriate name.  Probably with a "batman_adv_" prefix or
>> similar.
> 
> I aggree, but would like to like to have a shorter prefix batadv_. I know that 
> you said "or similar" but there are still some developers that fear your 
> response to a patch that only adds the prefix batadv_ instead of the longer 
> version.

batadv_ is fine.
