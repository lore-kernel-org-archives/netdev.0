From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: validate policer configuration TLVs
Date: Mon, 27 Dec 2004 18:34:24 -0800
Message-ID: <20041227183424.17cf34cc.davem@davemloft.net>
References: <20041207172349.GG1371@postel.suug.ch>
	<20041207213234.257fd0d9.davem@davemloft.net>
	<20041208203942.GO1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041208203942.GO1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Dec 2004 21:39:42 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> > Either these things are int's or u32's, they cannot be both :-)
> > I know that size wise it's identical, but at least make the code
> > look consistent.
> 
> OK, I changed the dereferencing to use u32 as well and have it "casted"
> while assigning the value since changing the structure datatypes
> wouldn't make sense.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
