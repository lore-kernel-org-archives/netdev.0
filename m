From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Tue, 6 Dec 2011 09:32:20 -0800
Message-ID: <20111206173220.GA28763@kroah.com>
References: <CAM7b5hzt8D6hn3=XEcm9E3_BwJxj-YABpkufCpuhjiPLDxCsMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Josh Boyer <jwboyer@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Ted Feng <artisdom@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM7b5hzt8D6hn3=XEcm9E3_BwJxj-YABpkufCpuhjiPLDxCsMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2011 at 05:25:24PM +0800, Ted Feng wrote:
> Same fix as 731abb9cb2 for ipip and sit tunnel.
> Commit 1c5cae815d removed an explicit call to dev_alloc_name in
> ipip_tunnel_locate
> and ipip6_tunnel_locate, because register_netdevice will now create a
> valid name.
> However the tunnel keeps a copy of the name in the private parms structure.
> 
> This shows up if you do a simple tunnel add, followed by a tunnel show:
> 
> $ sudo ip tunnel add mode ipip remote 10.2.20.211
> $ ip tunnel
> tunl0: ip/ip  remote any  local any  ttl inherit  nopmtudisc
> tunl%d: ip/ip  remote 10.2.20.211  local any  ttl inherit
> $ sudo ip tunnel add mode sit remote 10.2.20.212
> $ ip tunnel
> sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc 6rd-prefix 2002::/16
> sit%d: ioctl 89f8 failed: No such device
> sit%d: ipv6/ip  remote 10.2.20.212  local any  ttl inherit
> 
> Signed-off-by: Ted Feng <artisdom@gmail.com>

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
