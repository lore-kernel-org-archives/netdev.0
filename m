From: "David S. Miller" <davem@redhat.com>
Subject: Re: ethtool_features?
Date: Wed, 27 Aug 2003 23:52:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827235258.7229c8e1.davem@redhat.com>
References: <3F4D2F2B.2090401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F4D2F2B.2090401@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Aug 2003 18:22:35 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Hum.  Instead of adding all these _get_foo ops to test dev->features 
> bits, would anyone mind if I created a single _get_features() ethtool 
> sub-ioctl?

I'm personally OK with this _iff_ you add values local
to ethtool for the various feature bits.  Ie. don't
export the NETIF_F_* values to userspace.
