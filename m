From: Andi Kleen <ak@suse.de>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Wed, 14 May 2003 21:23:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514192305.GB31303@Wotan.suse.de>
References: <20030513210541.GA4415@suse.de> <20030513.163150.28800008.davem@redhat.com> <20030514080043.GA2575@suse.de> <20030514.121727.74733052.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olh@suse.de, marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030514.121727.74733052.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2003 at 12:17:27PM -0700, David S. Miller wrote:
> When you edit the layout of struct sock you assume
> the full responsibility that you might be breaking
> something that uses struct sock.  This includes
> third party modules.

What third party modules are you refering too ? 

I know openafs did or still does the cardinal sin of duplicating struct inode
and TCP has this hack too since ages, but other than that I hope 
"cut'n'paste" usage of structures is not common.

-Andi
