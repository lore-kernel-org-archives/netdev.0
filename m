From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left enabled.
Date: Thu, 07 Apr 2016 21:47:19 +0100
Message-ID: <5702.1460062039@warthog.procyon.org.uk>
References: <20160407.163616.385449823878901734.davem@davemloft.net> <20160407162309.21283.11482.stgit@warthog.procyon.org.uk> <1460046677.6715.95.camel@perches.com> <1091.1460058308@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, joe@perches.com,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407.163616.385449823878901734.davem@davemloft.net>
Content-ID: <5701.1460062039.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> > Excellent only if I can get at it to find out why the something went wrong.
> > If it's lost because the machine panics, then it is worthless.
> 
> If you're ok with these kenter things spewing into the logs with the
> current facility, you can run the function tracer and have it record
> into the logs all the time too.

They don't do that unless you enable them.  And I can enable them individually
at compile time or by set at runtime.

> I don't see any argument which is appropriate for keeping this stuff
> around.

Sigh.

As I said to Joe: I don't want to deal with converting to using ftrace at the
moment whilst I'm towards the end of reworking the rewrite of the code.  I
have a stack of patches that would need reworking yet again.

David
