From: jamal <hadi@cyberus.ca>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 18 Aug 2003 09:23:48 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1061213027.16017.2220.camel@jzny.localdomain>
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
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephan von Krawczynski <skraw@ithnet.com>, willy@w.ods.org,
	alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
	lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
	marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818055555.248f2a01.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-18 at 08:55, David S. Miller wrote:

> Under Linux, by default, IP addresses are owned by the system
> not by interfaces.  

Folks, the above is the punch line. I am just going over all emails on
this thread and i see this point being missed. 
People are quoting tons of RFCs while the really important point being
missed is the above line.

> For scenerios where this doesn't work, we have ways to make the
> kernel behave the way you want it to.
> 

and you are provided with alternatives if you dont like the way it
works. I think even Julian is happy with this.
Ok, heres a neat little feature requst: someone create arp rewrite rules
with ARPtable so we can have do MAC address aliasing.

Guys, Lets have Davem worry about more imporant things.
Maybe we should have a web page or FAQ on this topic?

cheers,
jamal

