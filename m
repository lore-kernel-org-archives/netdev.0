From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] vhost: Storage class should be before const qualifier
Date: Mon, 17 May 2010 15:27:48 +0200
Message-ID: <20100517132748.GQ9489@distanz.ch>
References: <1274101969-21109-1-git-send-email-tklauser@distanz.ch> <20100517131335.GA12126@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:33013 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab0EQNep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 09:34:45 -0400
Content-Disposition: inline
In-Reply-To: <20100517131335.GA12126@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-17 at 15:13:35 +0200, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Mon, May 17, 2010 at 03:12:49PM +0200, Tobias Klauser wrote:
> > The C99 specification states in section 6.11.5:
> > 
> > The placement of a storage-class specifier other than at the beginning
> > of the declaration specifiers in a declaration is an obsolescent
> > feature.
> > 
> > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> 
> 
> Will apply, thanks!
> Just to clarify: does some compiler/checker actually barf on this?

GCC does emit a warning if the options '-std=c99 -W -Wall' are present.
ICC also does warn about this, though I don't know whether this depends
on any commandline options.

Cheers
Tobias
