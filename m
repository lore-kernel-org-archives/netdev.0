From: "David S. Miller" <davem@redhat.com>
Subject: Re: [bernie@develer.com: Kernel 2.6 size increase]
Date: Wed, 23 Jul 2003 11:58:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723115858.75068294.davem@redhat.com>
References: <20030723195355.A27597@infradead.org>
	<20030723195504.A27656@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20030723195504.A27656@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 19:55:04 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Jul 23, 2003 at 07:53:55PM +0100, Christoph Hellwig wrote:
> > I think this is not only of interest fir the uClinux folks..
> 
> Sorry, this actually already Cc'ed lkml :)  Still the netdev folks
> should read it, too.

Well, we gained some code and a little bit of data, but
the BSS was cut in half which I think deserves noticing :-)

Also, he should analyze the amount of code that actually
gets executed for various tasks, comparing 2.4.x to 2.5.x

I'd take a half-meg code size hit if it meant that all
the normal code paths got cut in half :-)
