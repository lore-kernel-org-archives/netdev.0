From: Eric Leblond <eleblond@inl.fr>
Subject: Re: Netlink connector
Date: Mon, 25 Jul 2005 16:43:43 +0200
Message-ID: <1122302623.29940.20.camel@localhost.localdomain>
References: <20050723125427.GA11177@rama>
	 <20050723091455.GA12015@2ka.mipt.ru>
	 <20050724.191756.105797967.davem@davemloft.net>
	 <Lynx.SEL.4.62.0507250154000.21934@thoron.boston.redhat.com>
	 <20050725070603.GA28023@2ka.mipt.ru>  <42E4F800.1010908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Andrew Morton <akpm@osdl.org>,
	Harald Welte <laforge@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	netdev@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261272AbVGYOsk@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42E4F800.1010908@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 25 juillet 2005 =E0 16:32 +0200, Patrick McHardy a =E9crit :
> Evgeniy Polyakov wrote:
> > On Mon, Jul 25, 2005 at 02:02:10AM -0400, James Morris (jmorris@red=
hat.com) wrote:
> If I understand correctly it tries to workaround some netlink
> limitations (limited number of netlink families and multicast groups)
> by sending everything to userspace and demultiplexing it there.
> Same in the other direction, an additional layer on top of netlink
> does basically the same thing netlink already does. This looks like
> a step in the wrong direction to me, netlink should instead be fixed
> to support what is needed.

I totally agree with you, it could be great to fix netlink to support
multiple queue.
I like to be able to use projects like snort-inline or nufw together.
This will make Netfilter really stronger.
=46urthermore, there's a repetition of filtering capabilities with such=
 a
solution. Netfilter has to filter to send to netlink and this is the
same with the queue dispatcher. I think this introduce too much
complexity.
=20
my 0.02$

BR,
--=20
=C9ric Leblond, eleblond@inl.fr
T=E9l=E9phone : 01 44 89 46 40, Fax : 01 44 89 45 01
INL, http://www.inl.fr
