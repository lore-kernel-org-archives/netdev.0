From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NET]: Device mtu/txqlen/ifmap via rtnetlink.
Date: Wed, 25 Aug 2004 23:33:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825233330.15a82d29.davem@redhat.com>
References: <200408260506.i7Q56Ebq022683@hera.kernel.org>
	<412D832F.2070003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <412D832F.2070003@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2004 02:29:03 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Why are new calls to deprecated hook ->set_config() being added?

Because it's the only way to %100 implement ifconfig
using netlink.
