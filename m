From: "David S. Miller" <davem@davemloft.net>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 20:44:18 -0800
Message-ID: <20050121204418.2070d76d.davem@davemloft.net>
References: <41F1516D.5010101@hp.com>
	<200501211358.53783.jdmason@us.ibm.com>
	<41F163AD.5070400@hp.com>
	<20050121124441.76cbbfb9.davem@davemloft.net>
	<41F17B7E.2020002@hp.com>
	<20050121141820.7d59a2d1.davem@davemloft.net>
	<41F186A8.9030805@hp.com>
	<41F18927.5020607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F18927.5020607@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 14:58:47 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Speaking of divisor values... is zero (0) supposed to be a legal value?  The 
> sysctl seems to allow it but it does seem to behave a triffle strangely.  The 
> initial TSO size appeared to be 2MSS.

The value "0" behaves the same as "1".
