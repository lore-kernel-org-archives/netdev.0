From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN tagged
 {I,AR}P packets
Date: Tue, 7 Oct 2003 08:06:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007080640.50de4d45.davem@redhat.com>
References: <200310062204.07230.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org, greearb@candelatech.com,
        vlan@wanfear.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200310062204.07230.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Oct 2003 22:04:07 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> -	unsigned long hh[16 / sizeof(unsigned long)];
> +	unsigned char hh[18];

Maybe don't do this?  It should be aligned on a 'long' boundry I
think.

The only real hard objection I have with the patch is the vlan xmit
routine pointer crap, just export the symbol.

Once you fix that I'll apply your patch as long as Stephen has no
objections.
