From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge
 device
Date: Sat, 30 Aug 2003 20:30:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830203043.0eb1a660.davem@redhat.com>
References: <200308301504.03241.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200308301504.03241.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Aug 2003 15:04:03 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> The patch below disables making vlan devices on top of bridge
> devices, f.e. br0.12 would be impossible.

I don't think disallowing this merely for the sake of
implementation convenience is such a good idea.  And
from other people's comments, such setups might even
be useful.
