From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH beta 1] 0/3] Fix race conditions in mrf24j40 interrupts
Date: Tue, 21 May 2013 22:03:59 -0400
Message-ID: <519C278F.5030809@signal11.us>
References: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com> <1369188080-8904-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: david@hauweele.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369188080-8904-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/21/2013 10:01 PM, Alan Ott wrote:
> David Hauweele noticed that the mrf24j40 would hang arbitrarily after some
> period of heavy traffic.  Two race conditions were discovered, and the
> driver was changed to use threaded interrupts, since the enable/disable of
> interrupts in the driver has recently been a lighning rod whenever issues
> arise related to interrupts (costing engineering time), and since threaded
> interrupts are the right way to do it.
>
> Alan Ott (3):
>   mrf24j40: Move INIT_COMPLETION() to before packet transmission
>   mrf24j40: Use threaded IRQ handler
>   mrf24j40: Use level-triggered interrupts
>
>  drivers/net/ieee802154/mrf24j40.c | 31 +++++++++----------------------
>  1 file changed, 9 insertions(+), 22 deletions(-)

I forgot to add, I ran ping -f both ways all afternoon (6.5 hours), and
it seems solid.
