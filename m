From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] TCP congestion schedulers
Date: Mon, 21 Mar 2005 13:51:54 -0800
Message-ID: <20050321135154.0bbeae85.davem@davemloft.net>
References: <421CF5E5.1060606@ev-en.org>
	<20050223135732.39e62c6c.davem@davemloft.net>
	<421D1E66.5090301@osdl.org>
	<421D30FA.1060900@ev-en.org>
	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>
	<20050309210442.3e9786a6.davem@davemloft.net>
	<4230288F.1030202@ev-en.org>
	<20050310182629.1eab09ec.davem@davemloft.net>
	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	<20050311201011.360c00da.davem@davemloft.net>
	<20050314151726.532af90d@dxpl.pdx.osdl.net>
	<m13bur5qyo.fsf@muc.de>
	<Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, shemminger@osdl.org, baruch@ev-en.org, netdev@oss.sgi.com
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 16:25:56 -0500 (EST)
John Heffner <jheffner@psc.edu> wrote:

> Would you really expect a single extra indirect call per ack to have a
> significant performance impact?  This is surprising to me.  Where does the
> cost come from?  Replacing instruction cache lines?

Maybe not for ACK processing (that's very thick already) but
perhaps for a lighter fast path definitely so.
