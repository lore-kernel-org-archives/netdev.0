From: Ted Feng <artisdom@gmail.com>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Sat, 10 Dec 2011 22:29:24 +0800
Message-ID: <20111210142920.GA3988@gmail.com>
References: <CAM7b5hzt8D6hn3=XEcm9E3_BwJxj-YABpkufCpuhjiPLDxCsMQ@mail.gmail.com>
 <20111206173220.GA28763@kroah.com>
 <CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
 <20111207.235602.1465915988125994516.davem@davemloft.net>
 <20111208104619.GA20150@ted-OptiPlex-380>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111208104619.GA20150@ted-OptiPlex-380>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 08, 2011 at 06:46:21PM +0800, Ted Feng wrote:
> From: Ted Feng <artisdom@gmail.com>
> 
> Same fix as 731abb9cb2 for ipip and sit tunnel.
> Commit 1c5cae815d removed an explicit call to dev_alloc_name in
> ipip_tunnel_locate and ipip6_tunnel_locate, because register_netdevice
> will now create a valid name, however the tunnel keeps a copy of the
> name in the private parms structure. Fix this by copying the name back
> after register_netdevice has successfully returned.
> 
Just a reminder. The previous resubmited patch got no response.
