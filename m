From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bridge (2.6.5) -- correctl handle up to 256 ports per
 bridge
Date: Thu, 1 Apr 2004 14:13:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401141346.69236947.davem@redhat.com>
References: <406B251B.9050907@usr.fi>
	<20040401093618.49cca9fa@dell_ss3.pdx.osdl.net>
	<406CA0D7.6020500@usr.fi>
	<20040401135746.0f985897@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: weeti@usr.fi, bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040401135746.0f985897@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 1 Apr 2004 13:57:46 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Bridge code is limited to 256 ports per bridge because the Spanning
> Tree Protocol has limit of one octet for port number.  This code
> fixes:
> 	* bogus unlock in error path when port list is full.
> 	* passes different error status for out of memory, vs
> 	  port list full.
> 	* O(n) vs O(n^2) lookup for free port number
> 	* since port and priority are both limited to one byte
> 	  don't store them as int's
> 	* makes limit explicit in code

Applied, thanks Stephen.
