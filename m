From: "Bryan O'Sullivan" <bos@keyresearch.com>
Subject: Re: [ANNOUNCE] netplug, a daemon that handles network cables
	getting plugged in and out
Date: 29 Aug 2003 10:43:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062178992.12285.130.camel@serpentine.internal.keyresearch.com>
References: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>
	 <20030829003426.GF12249@vitelus.com>  <3F4EB641.3040107@davehollis.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Aaron Lehmann <aaronl@vitelus.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David T Hollis <dhollis@davehollis.com>
In-Reply-To: <3F4EB641.3040107@davehollis.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-08-28 at 19:11, David T Hollis wrote:

> Hmm, that seems to raise the question - why doesn't dhclient just handle 
> that?

Because it has as little knowledge of how the OS works as possible. 
It's intended to run on all kinds of Unix platforms, not just Linux.

> On a DHCP interface, it's running anyway.  if it paid attention 
> to link status, it would know when to re-request an IP.

There are no cross-platform standards for this kind of thing, so they'd
need modules for Linux, FreeBSD, Solaris, AIX, etc., etc.  I'm sure
they'd be happy to accept patches.

	<b
