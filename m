From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 20 Nov 2012 09:21:26 +0000
Message-ID: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	<1349790863.21172.4406.camel@edumazet-glaptop>
	<1349792241.21847.199.camel@zakaz.uk.xensource.com>
	<1349792847.21172.4479.camel@edumazet-glaptop>
	<1349793630.21847.208.camel@zakaz.uk.xensource.com>
	<1349863984.10070.26.camel@zakaz.uk.xensource.com>
	<1349874598.10070.39.camel@zakaz.uk.xensource.com>
	<748966751.20121010164949@eikelenboom.it>
	<1349942546.14806.7.camel@zakaz.uk.xensource.com>
	<151954917.20121011120004@eikelenboom.it>
	<1349949924.21172.8462.camel@edumazet-glaptop>
	<1349950494.14806.29.camel@zakaz.uk.xensource.com>
	<50A4540E.1010601@oracle.com>
	<1333495676.20121119164304@eikelenboom.it>
	<50AB3F9D.4070905@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Konrad
	Rzeszutek Wilk <konrad@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Marcos E. Matsunaga" <Marcos.Matsunaga@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Sander Eikelenboom <linux@eikelenboom.it>, ANNIE LI <annie.li@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <50AB3F9D.4070905@canonical.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-20 at 08:30 +0000, Stefan Bader wrote:
> >> When I tried to rebase my persistent grant netfront/netback patch on 
> >> latest kernel, netperf/netserver test never succeeded. I did some test 
> >> to find out that v3.6-rc7 works fine, but v3.7-rc1, v3.7-rc2 and 
> >> v3.7-rc4 does not succeed in netperf/netserver test. So I keep my 
> >> persistent grant patch only based on v3.4-rc3 now.
> > 
> >> Konrad thought about commit 6a8ed462f16b8455eec5ae00eb6014159a6721f0 in 
> >> v3.7-rc1, and suggested me to test your debug patch in netfront. This 
> >> BUG_ON happens soon after running the netperf/netserver test case.
> > 
> >> Thanks
> >> Annie
> > 
> > Is there any progression with this bug (rc6 is out the door, so the
> release of 3.7-final seems to be eminent and this bug completely
> cripples any networking with guests) ?
> > 
> 
> +1 on that. I was testing yesterday with a PVM domU running 3.7-rc5 on Xen 4.2
> (but also reported from EC2 running Xen 3.4.3) c with one VCPU. I actually can
> trigger it by just ssh'ing into the domU (from another machine) and then run
> "find /". Output starts to stutter and then stops completely. When this happens
> a new connection still can be made and as long as only shorter output is
> generated the ssh connection is ok. From a dump taken it looks like user-space
> is waiting in some select call (without any warnon I rather won't see the tx path).

Annie, are you still looking into this or shall I?

Ian.
