From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been
 left enabled.
Date: Thu, 07 Apr 2016 16:36:16 -0400 (EDT)
Message-ID: <20160407.163616.385449823878901734.davem@davemloft.net>
References: <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
	<1460046677.6715.95.camel@perches.com>
	<1091.1460058308@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1091.1460058308@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 07 Apr 2016 20:45:08 +0100

> David Miller <davem@davemloft.net> wrote:
> 
>> Yeah this custom stuff is really inappropriate given the excellent
>> infrastructure we have these days...
> 
> Excellent only if I can get at it to find out why the something went wrong.
> If it's lost because the machine panics, then it is worthless.

If you're ok with these kenter things spewing into the logs with the
current facility, you can run the function tracer and have it record
into the logs all the time too.

I don't see any argument which is appropriate for keeping this stuff
around.
