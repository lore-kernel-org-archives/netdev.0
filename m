From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: impressive throughput on 2.5.73
Date: 02 Jul 2003 20:20:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057202451.2916.36.camel@nighthawk>
References: <1057193766.31286.843.camel@nighthawk>
	 <3F039BE1.2080008@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Scott Feldman <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3F039BE1.2080008@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-07-02 at 19:58, Nivedita Singhvi wrote:
> Nice numbers :). In addition to NAPI, would be nice to
> stick in more adapters. Any idea why __wake_up should be
> so expensive on the client side?

NAPI seems to degrade throughput down to ~80MB/sec, but the interrupt
rate doesn't change.  I'm going to put some debugging in and makes sure
that it's kicking in properly.

-- 
Dave Hansen
haveblue@us.ibm.com
