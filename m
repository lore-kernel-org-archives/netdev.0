From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 07:28:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818072833.1ea7a81b.davem@redhat.com>
References: <200308171759540391.00AA8CAB@192.168.128.16>
	<1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk>
	<200308171827130739.00C3905F@192.168.128.16>
	<1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk>
	<20030817224849.GB734@alpha.home.local>
	<20030817223118.3cbc497c.davem@redhat.com>
	<20030818133957.3d3d51d2.skraw@ithnet.com>
	<20030818044419.0bc24d14.davem@redhat.com>
	<20030818125158.GA18699@alpha.home.local>
	<20030818055329.44db9262.davem@redhat.com>
	<20030818142847.GA19910@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030818142847.GA19910@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 16:28:47 +0200
Willy Tarreau <willy@w.ods.org> wrote:

> Now if you think that the behaviour I'm proposing is broken, please explain me
> why.

If the user overrides the source address (which is the case I believe
you're talking about, there are so many cases it's hard for me
to keep track) then HE KNOWS WHAT HE IS DOING even if using that
source address to talk to a particular remote address makes no sense.
