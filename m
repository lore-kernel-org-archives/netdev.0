From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: 2.6.7: sk98lin unload oops
Date: Wed, 7 Jul 2004 23:50:44 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407072350.44252.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200407041342.18821.bernd-schubert@web.de> <20040704151509.GA5100@infradead.org> <20040704152352.GA5243@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>,
        Bernd Schubert <bernd-schubert@web.de>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
In-Reply-To: <20040704152352.GA5243@infradead.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 04 July 2004 18:23, Christoph Hellwig wrote:
> On Sun, Jul 04, 2004 at 04:15:09PM +0100, Christoph Hellwig wrote:
> > > Fortunality everything still works fine (I'm running the script over
> > > the network of the syskonnect cards).
> > >
> > > This machine has two of those syskonnect cards, on another machine
> > > which has only one syskonnect card this oops doesn't occur.
> >
> > As a colleteral damage the following huge patch should fix it, and I need
> > testers for it anyway ;-)
>
> Actually the problem sits deeper.  sk98line tries to register a procfile
> with the interfacename of the struct net_device.  The patch below (ontop of
> the previous one) makes it work unless you change the interface name
> manually, but as Linux explicitly allows that the interface is
> fundamentally broken and probably should just go away.

hostap driver does this too
--
vda
