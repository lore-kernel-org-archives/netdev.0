From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 16:23:10 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030818162310.4106c8c6.skraw@ithnet.com>
References: <20030728213933.F81299@coredump.scriptkiddie.org>
	<200308171509570955.003E4FEC@192.168.128.16>
	<200308171516090038.0043F977@192.168.128.16>
	<1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
	<200308171555280781.0067FB36@192.168.128.16>
	<1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk>
	<200308171759540391.00AA8CAB@192.168.128.16>
	<1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk>
	<200308171827130739.00C3905F@192.168.128.16>
	<1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk>
	<20030817224849.GB734@alpha.home.local>
	<20030817223118.3cbc497c.davem@redhat.com>
	<20030818133957.3d3d51d2.skraw@ithnet.com>
	<20030818044419.0bc24d14.davem@redhat.com>
	<20030818143401.1352d158.skraw@ithnet.com>
	<20030818053007.7852ca77.davem@redhat.com>
	<20030818145316.3a81f70c.skraw@ithnet.com>
	<20030818055555.248f2a01.davem@redhat.com>
	<20030818151755.47096672.skraw@ithnet.com>
	<20030818061420.6255f3d9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
	lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
	marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818061420.6255f3d9.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 06:14:20 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Mon, 18 Aug 2003 15:17:55 +0200
> Stephan von Krawczynski <skraw@ithnet.com> wrote:
> 
> > If I remember that right kernels 2.0 and 2.2 behave differently, so
> > you are talking about setups for 2.4 kernels.
> 
> All kernel versions have had the ARP behavior we have now.

They have not. I just tried.

I have two boxes with 2 interfaces each and a third for testing. Testbox 1 has
2.2 kernel, testbox 2 has 2.4 kernel.

The three are connected via same switch on primary if.

I ping the second if ip of testbox 2, then arp -vn and see the second ip with
a mac entry of testbox 2 primary if.
I ping the second if ip of testbox 1, then arp -vn and see _no_ entry for this
second ip, it is in fact routed (which I would state as the expected
behaviour as the second ip is from another subnet).
 
> Both 2.0 and 2.2 answer on all interfaces for ARP requests
> by default just like 2.4 does.

Try it. Proven wrong. See above.
 
Regards,
Stephan
