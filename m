From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: Sat, 30 Aug 2003 15:21:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308301521.42279.bdschuym@pandora.be>
References: <200308301504.03241.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
In-Reply-To: <200308301504.03241.bdschuym@pandora.be>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 30 August 2003 15:04, Bart De Schuymer wrote:
> Also, situations like eth0.15 being a bridge port of br0.16 seem
> unwanted (to me).

That should be: eth0.15 being a bridge port of br0, and sending locally 
generated traffic through br0.15.

cheers,
Bart
