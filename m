From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix bridge-nf with IP defragmentation
Date: Sun, 21 Dec 2003 12:02:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031221120239.16356d2c.davem@redhat.com>
References: <200312211258.36325.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312211258.36325.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Dec 2003 12:58:36 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> This patch fixes IP defragmentation for bridged packets.
> nf_bridge_info.hh is renamed to nf_bridge_info.data,
> the bridge-nf IP code no longer uses the control buffer and a very
> necessary call of nf_bridge_put is added to ip_output.c (and ip6_output.c).

Please make this relative to the previous patch which I already
applied.
