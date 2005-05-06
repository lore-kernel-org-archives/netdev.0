From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ: Reordering?
Date: Sat, 07 May 2005 01:19:14 +0200
Message-ID: <427BFB72.7080407@trash.net>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050506230203.GI28419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> We can maintain a second hash table and switch a pointer over to the
> new table but keep on dequeueing from the old one until it is empty.
> Anyways, any such behaviour should be made optional via a rtnetlink
> flag.

This also introduces unfairness. Packets of a flow could be only in
the new table while we're still working on the active table.
A proper solution to avoid reordering shouldn't be optional IMO,
perturbation is already optional.

Regards
Patrick
