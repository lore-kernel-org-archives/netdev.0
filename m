From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Thu, 02 Sep 2004 16:33:31 -0400
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <4137839B.4000303@pobox.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4134C1A7.50600@pobox.com> <200409022324.43117.vkondra@mail.ru>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
 Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
 Jean Tourrilhes <jt@bougret.hpl.hp.com>,
 Jouni Malinen <jkmaline@cc.hut.fi>,
  acx100-devel@lists.sourceforge.net,  prism54-devel@prism54.org,
 "David S. Miller" <davem@redhat.com>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409022324.43117.vkondra@mail.ru>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

Vladimir Kondratiev wrote:
> Jeff,
> 
> On Tuesday 31 August 2004 21:21, Jeff Garzik wrote:
> JG> Denis Vlasenko wrote:
> JG> > I think 'senior' network guys are in position to decide upon which
> JG> > of currently available 802.11 stacks we should continue to work.
> JG> > (Atheros has one, said to be derived from BSD, is there any others?)
> JG>
> JG>
> JG> Already have.  Start with the code in wireless-2.6 -- HostAP -- and use
> JG> DaveM's 802.11 stack template as a model for actually integrating 802.11
> JG> very tightly with the rest of the net stack.
> JG>
> JG>
>  http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p8
> 0211.tar.bz2 
> 
> Is this stack the main one that is going to be used? I.e. if I am working on 
> driver for next generation .11 card - should I try to use it, request/submitt 
> missing features etc.? Or should I use wireless extensions?

DaveM's code is a template for how a wireless stack would look when 
properly and fully integrated into the net core.

Although JeanT and I disagree about this, I am less interested in 
backwards compatibility than I am about making wireless a "first class 
citizen" in the kernel.  As I have proven with kcompat 
(http://sf.net/projects/gkernel/) you can be backwards compatible while 
still evolving the current kernel driver API to meet current design needs.

	Jeff




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
