From: "David S. Miller" <davem@davemloft.net>
Subject: Re: design for TSO performance fix
Date: Thu, 27 Jan 2005 16:58:22 -0800
Message-ID: <20050127165822.0e97a046.davem@davemloft.net>
References: <20050127163146.33b01e95.davem@davemloft.net>
	<41F98C93.9040005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F98C93.9040005@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 16:51:31 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Does anything (need to) change wrt getting the size of the TSO's to increase as 
> cwnd increases?

Nope, we use the same algorithm we use currently to determine
the "TSO mss", except that we compute and apply it at the correct
moment.
