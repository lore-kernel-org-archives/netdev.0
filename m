From: "David S. Miller" <davem@redhat.com>
Subject: Re: Making the NS83820 usable on IA64
Date: Tue, 16 Mar 2004 21:49:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316214912.32b4c530.davem@redhat.com>
References: <16471.52400.222262.824746@wombat.disy.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ia64@vger.kernel.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
In-Reply-To: <16471.52400.222262.824746@wombat.disy.cse.unsw.edu.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Mar 2004 14:57:36 +1100
Peter Chubb <peterc@gelato.unsw.edu.au> wrote:

> The idea is to tell gcc that the IP header is 2-byte aligned,
> so it can generate the right code to access it.  Otherwise, it tries
> to do a 4-byte load when trying to extract the header length bitfield,
> which traps.  As far as I read the C standard, gcc can do almost
> whatever it wants as regarding the alignment and underlying storage
> size of a bitfield, so it's free to assume 32-bit alignment if it
> wants.

This makes every piece of code only able to assume 2-byte
alignment.  I don't think this will get accepted :)
