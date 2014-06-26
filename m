From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 3/3 RFC] pktgen: Allow sending TCP packets
Date: Wed, 25 Jun 2014 17:41:47 -0700
Message-ID: <CAHA+R7NR4PmLbwmKXL8iwdwm3STNmpT4iZCp3VgB2zAqWZm7XQ@mail.gmail.com>
References: <1403728972-29548-1-git-send-email-zoltan.kiss@citrix.com>
	<1403728972-29548-4-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Mathias Krause <minipli@googlemail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Joe Perches <joe@perches.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403728972-29548-4-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 1:42 PM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> This is a prototype patch to enable sending TCP packets with pktgen. The
> original motivation is to test TCP GSO with xen-netback/netfront, but I'm not
> sure about how the checksum should be set up, and also someone should verify the
> GSO settings I'm using.
>

What's the point of sending TCP packets since you don't establish a TCP
connection?
