From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 11:23:07 -0800
Message-ID: <20050212112307.00fefaa2.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<20050211150420.74737b2e@dxpl.pdx.osdl.net>
	<20050211170740.2608419b.davem@davemloft.net>
	<m1fz02f05c.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hubert.tonneau@fullpliant.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        niv@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1fz02f05c.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Feb 2005 13:11:43 +0100
Andi Kleen <ak@muc.de> wrote:

> "David S. Miller" <davem@davemloft.net> writes:
> >
> > I guess this is e1000.  Any e1000 internals experts reading
> > here who can comment on how e1000's TSO engine treats the
> > PSH flag?
> 
> If that is the problem it should be easy to test for. Just
> disable TSO with ethtool -K ethX tso off
> 
> Hubert, does that make the problem go away?

We're testing the new code that sets PSH on every TSO frame.
If we disable TSO, the new code won't be exercised nor tested.
:-)
