From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] don't require ip_forwarding for reset on a bridge
Date: Mon, 29 Mar 2004 20:30:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329203025.4d272b55.davem@redhat.com>
References: <200403292314.12855.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200403292314.12855.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Mar 2004 23:14:12 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> Currently, to be able to send a reset in the FORWARD chain of iptables
> for bridged traffic, ip forwarding must be enabled. This causes confusion
> and in some situations people really don't want to enable ip forwarding.
> The patch below lets the user send reset packets for bridged frames in
> the FORWARD chain, with ip forwarding disabled (as long as there is a
> route).

I want an ACK from the netfilter folks before applying this one.
