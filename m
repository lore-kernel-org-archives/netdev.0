From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH/RESEND] fix bridge-nf fragment memory leak
Date: Wed, 31 Dec 2003 10:33:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231103327.568eab7d.davem@redhat.com>
References: <200312311148.14226.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312311148.14226.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Dec 2003 11:48:14 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> I don't see this patch in Linus' tree, so here's a resend...
> 
> This patch fixes IP defragmentation for bridged packets.
> nf_bridge_info.hh is renamed to nf_bridge_info.data,
> the bridge-nf IP code no longer uses the control buffer and a very
> necessary call of nf_bridge_put is added to ip_output.c (and ip6_output.c).

I just noticed that I didn't merge this too, last night right
before going to sleep :)

I had it in a seperate tree, and I will merge it in today.

Thanks for reminding me.
