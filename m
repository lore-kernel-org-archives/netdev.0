From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 11:26:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008112657.2adddeb6.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F844EF9.9090901@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3F844EF9.9090901@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 08 Oct 2003 12:52:57 -0500
John Partridge <johnip@sgi.com> wrote:

> Not too much different

The problem is that your change is arch-dependant yet you make it
run on all platforms.

On x86 we don't want to do what your change is doing, the unaligned
accesses are cheap enough.

We need to abstract this, probably in the same way it is done in
the Tulip and other drivers which have similar issues.
