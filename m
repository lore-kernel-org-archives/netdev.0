From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 17:07:40 -0800
Message-ID: <20050211170740.2608419b.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<20050211150420.74737b2e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hubert.tonneau@fullpliant.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        niv@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050211150420.74737b2e@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 15:04:20 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Still not setting Push sufficiently to keep MacOSX happy.

I don't think it's the kernel's fault in this case.

This set of data frames you quoted are all full, and
are tightly interspaced.  It looks exactly like a TSO
frame, which we certainly set PSH on, but the TSO
engine is dropping it aparently.

I guess this is e1000.  Any e1000 internals experts reading
here who can comment on how e1000's TSO engine treats the
PSH flag?
