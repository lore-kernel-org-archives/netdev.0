From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix bridge-nf with IP defragmentation
Date: Sun, 21 Dec 2003 12:24:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031221122417.191614ef.davem@redhat.com>
References: <200312211258.36325.bdschuym@pandora.be>
	<20031221120239.16356d2c.davem@redhat.com>
	<200312212115.10508.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312212115.10508.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 21 Dec 2003 21:15:10 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> The only difference is the change to ip6_output.c, which is right now
> purely cosmetic since bridged ipv6 traffic isn't yet seen by ip6tables.
> But it's best to do it now as it might be forgotten later...

Thanks a lot Bart, I'll apply this.
