From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been
 left enabled.
Date: Thu, 07 Apr 2016 10:19:05 -0700
Message-ID: <1460049545.6715.98.camel@perches.com>
References: <1460046677.6715.95.camel@perches.com>
	 <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
	 <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
	 <24286.1460048722@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24286.1460048722@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-07 at 18:05 +0100, David Howells wrote:
> Joe Perches <joe@perches.com> wrote:
> > It might be better to remove kenter and _enter
> > altogether and use function tracing instead.
> Possibly - but not at this time.

Swell.

> Besides, isn't the function tracing log lost
> if the machine crashes?

I believe yes, but would it matter?
