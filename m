From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Fri, 3 Sep 2004 20:37:54 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409032039.28201.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409022324.43117.vkondra@mail.ru> <4137839B.4000303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Jouni Malinen <jkmaline@cc.hut.fi>, acx100-devel@lists.sourceforge.net,
        prism54-devel@prism54.org, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <4137839B.4000303@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is anyone working on this stack? I asked Dave, he is hot working on it.
Or is this code dead?

On Thursday 02 September 2004 23:33, Jeff Garzik wrote:
JG> Vladimir Kondratiev wrote:
JG> > Jeff,
JG> >
JG> > On Tuesday 31 August 2004 21:21, Jeff Garzik wrote:
JG> > JG> Denis Vlasenko wrote:
JG> > JG> > I think 'senior' network guys are in position to decide upon
 which JG> > JG> > of currently available 802.11 stacks we should continue to
 work. JG> > JG> > (Atheros has one, said to be derived from BSD, is there
 any others?) JG> > JG>
JG> > JG>
JG> > JG> Already have.  Start with the code in wireless-2.6 -- HostAP -- and
 use JG> > JG> DaveM's 802.11 stack template as a model for actually
 integrating 802.11 JG> > JG> very tightly with the rest of the net stack.
JG> > JG>
JG> > JG>
JG> > 
 http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p8
 JG> > 0211.tar.bz2
JG> >
JG> > Is this stack the main one that is going to be used? I.e. if I am
 working on JG> > driver for next generation .11 card - should I try to use
 it, request/submitt JG> > missing features etc.? Or should I use wireless
 extensions?
JG>
JG> DaveM's code is a template for how a wireless stack would look when
JG> properly and fully integrated into the net core.
JG>
JG> Although JeanT and I disagree about this, I am less interested in
JG> backwards compatibility than I am about making wireless a "first class
JG> citizen" in the kernel.  As I have proven with kcompat
JG> (http://sf.net/projects/gkernel/) you can be backwards compatible while
JG> still evolving the current kernel driver API to meet current design
 needs. JG>
JG> 	Jeff
JG>
JG>
JG>
JG>
