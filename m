From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] make lock/release_sock fast calls
Date: Thu, 1 Apr 2004 05:45:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401054521.A16112@infradead.org>
References: <20040331112407.66309027@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040331112407.66309027@dell_ss3.pdx.osdl.net>; from shemminger@osdl.org on Wed, Mar 31, 2004 at 11:24:07AM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2004 at 11:24:07AM -0800, Stephen Hemminger wrote:
> lock_sock and release_sock are no longer inline, but they are called in
> the critical path of many operations, so it makes sense to use register based
> fastcall.

Not sure I agree.  If you care for performance you compile with
CONFIG_REGPARAM set, no?
