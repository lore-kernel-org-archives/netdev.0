From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.4.26-pre1] Allow ebtables module to change protocol in
 netif_receive_skb
Date: Thu, 26 Feb 2004 11:57:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226115709.4ed1594d.davem@redhat.com>
References: <AC8C1F46CD753F4AAC8F890E35A9EB461C670B@webmail.instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, bdschuym@pandora.be
Return-path: <netdev-bounce@oss.sgi.com>
To: "Simon Barber" <simon@instant802.com>
In-Reply-To: <AC8C1F46CD753F4AAC8F890E35A9EB461C670B@webmail.instant802.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 14:47:41 -0800
"Simon Barber" <simon@instant802.com> wrote:

> Currently skb->protocol is read before the bridge is called, even though
> it's not used until after. Hence if an ebtables module changes the
> protocol of a frame the wrong protocol is interpreted.

Applied, even though ebtables is not in 2.4.x yet the change is valid.
I've applied your 2.6.x variant too of course.

Thanks Simon.
