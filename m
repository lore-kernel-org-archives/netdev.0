From: Andi Kleen <ak@muc.de>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 13:11:43 +0100
Message-ID: <m1fz02f05c.fsf@muc.de>
References: <0525M9211@server5.heliogroup.fr>
	<20050211150420.74737b2e@dxpl.pdx.osdl.net>
	<20050211170740.2608419b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hubert.tonneau@fullpliant.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        niv@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050211170740.2608419b.davem@davemloft.net> (David S.
 Miller's message of "Fri, 11 Feb 2005 17:07:40 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:
>
> I guess this is e1000.  Any e1000 internals experts reading
> here who can comment on how e1000's TSO engine treats the
> PSH flag?

If that is the problem it should be easy to test for. Just
disable TSO with ethtool -K ethX tso off

Hubert, does that make the problem go away?

-Andi
