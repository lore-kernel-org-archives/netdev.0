From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 13:59:14 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307111358440.27351-100000@netcore.fi>
References: <20030711.195917.89662318.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: mika.liljeberg@welho.com, <andre@tomt.net>, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030711.195917.89662318.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0307111347090.27351-100000@netcore.fi> (at Fri, 11 Jul 2003 13:47:48 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
> 
> > On Fri, 11 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> > > In article <Pine.LNX.4.44.0307111301520.27036-100000@netcore.fi> (at Fri, 11 Jul 2003 13:03:54 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
> > > 
> > > > > We have but we cannot; it is refcnt'ed.
> > > > 
> > > > I don't understand what you mean.  Refcnt'ed by a userland process, so 
> > > > that if you'd want the subnet-router anycast address, the whole time a 
> > > > process (like radvd) should be running.. or what?
> > > 
> > > Kernel has refcnt for subnet router anycast address.
> > > Ref/dereference from userspace is done via socket.
> > > You cannot derefer subnet router anycast address 
> > > from userspace if the socket hasn't refered it.
> > 
> > So?  The point is that subnet router anycast address *could* be referenced 
> > explicitly by a user-land socket (e.g. by radvd), not kernel at all.
> 
> So, you cannot remove subnet router anycast address from
> kernel via this interface; kernel keeps one reference.

.. which is why kernel shouldn't keep *any* reference *at all*!
 
> (Hmm, I may misunderstand your mail...)

.. seems like it..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
