From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Wed, 21 May 2003 21:52:58 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522005258.GC13028@conectiva.com.br>
References: <20030513210541.GA4415@suse.de> <20030513.163150.28800008.davem@redhat.com> <20030514083236.GD8290@Wotan.suse.de> <20030514.121806.41651014.davem@redhat.com> <20030514192117.GA31303@Wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, olh@suse.de,
   marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030514192117.GA31303@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 14, 2003 at 09:21:17PM +0200, Andi Kleen escreveu:
> On Wed, May 14, 2003 at 12:18:06PM -0700, David S. Miller wrote:
> >    From: Andi Kleen <ak@suse.de>
> >    Date: Wed, 14 May 2003 10:32:36 +0200
> > 
> >    On Tue, May 13, 2003 at 04:31:50PM -0700, David S. Miller wrote:
> >    > It's documented in tcp.h already.
> >    
> >    Just not everybody changing sock.h also reads tcp.h :-(
> > 
> > You assume that protocols in the tree are the only thing
> > that might break if you edit struct sock.
> 
> I'm not assuming anything and didn't even edit struct sock, just pointing 
> out that such a fragile hack as the current tw bucket is needs an explicit 
> comment on both places.
> 
> Best would be to bite the bullet and give them a common structure.

Ah if we could just use a unnamed struct... 8)

- Arnaldo
