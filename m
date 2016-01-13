From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable-3.2 stable-3.12] net: fix checksum check in
 skb_copy_and_csum_datagram_iovec()
Date: Wed, 13 Jan 2016 06:51:27 -0800
Message-ID: <1452696687.1223.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
	 <568BF0FD.4010208@suse.cz> <1452012008.2768.82.camel@decadent.org.uk>
	 <1452682920.7020.32.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>, Michal Kubecek <mkubecek@suse.cz>,
	stable@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1452682920.7020.32.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-13 at 11:02 +0000, Ben Hutchings wrote:
> On Tue, 2016-01-05 at 16:40 +0000, Ben Hutchings wrote:
> > On Tue, 2016-01-05 at 17:36 +0100, Jiri Slaby wrote:
> > > On 12/28/2015, 03:01 PM, Michal Kubecek wrote:
> > > > Recent fix "net: add length argument to
> > > > skb_copy_and_csum_datagram_iovec" added to some pre-3.19 stable
> > > > branches, namely
> > > > 
> > > >   stable-3.2.y: commit 127500d724f8
> > > >   stable-3.12.y: commit 3e1ac3aafbd0
> > > 
> > > Applied this fix to 3.12. Thanks!
> > [...]
> > 
> > You don't want this, you want Eric's fix (commit 197c949e7, "udp:
> > properly support MSG_PEEK with truncated buffers") although that's not
> > upstream yet.
> 
> It's now upstream as commit 197c949e7798fbf28cfadc69d9ca0c2abbf93191.
> 
> Ben.
> 

Indeed, thanks guys for your backports !
