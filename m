From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Route cache performance under stress
Date: Sun, 8 Jun 2003 20:58:57 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306082054180.3737-100000@netcore.fi>
References: <87he70re62.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <87he70re62.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Jun 2003, Florian Weimer wrote:
> "David S. Miller" <davem@redhat.com> writes:
> 
> >    Of course, this will result in vastly decreased functionality (no
> >    arbitary netmasks, no policy-based routing, code will be fine-tuned
> >    for typical Internet routing tables), so this proposal definitely
> >    comes at a price.
> >
> > As a general purpose operating system, where people DO in fact use
> > these features quite regularly,
> 
> Even non-CIDR netmasks?  AFAIK, it's hard to find dedicated networking
> devices (and routing protocols!) which support them. 8-/

Do you mean netmasks like "255.128.255.0" ?  Those are a real 
abomination and probably not supported.. and I don't know of anything that 
would require them.

Or do you mean netmasks such as 1.1.1.1/19?  I don't know of any credible 
networking devices which wouldn't support them.  If so, please come out of 
the cave.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
