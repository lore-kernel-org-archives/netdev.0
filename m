From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Wed, 16 Feb 2005 12:13:23 +0300
Message-ID: <20050216091323.GA26758@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <20050211150420.74737b2e@dxpl.pdx.osdl.net> <20050215152354.46a08d77.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, hubert.tonneau@fullpliant.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru, niv@us.ibm.com,
        rick.jones2@hp.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050215152354.46a08d77.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> How mind boggling a heuristic.  I bet it works by accident rather
> than intention and purposeful design.

Yup. It is definitely not an "ack avoidance algorithm" :-) :-)

BTW it is still a puzzle why 2.6.9 works. With disabled TSO it should
insert PSHs quite rarely, similarly to tso.

And it is still a puzzle how that bunch of PSHless segments not followed
by PSH appeared in TSO case.

Alexey
