From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Fri, 9 Jul 2004 16:14:12 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040709161412.4fee5b04.davem@redhat.com>
References: <20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
	<20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
	<20040706194034.GA11021@mail.shareable.org>
	<20040706131235.10b5afa8.davem@redhat.com>
	<20040706224453.GA6694@outpost.ds9a.nl>
	<20040706154907.422a6b73.davem@redhat.com>
	<20040707110653.7c49bef1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, jamie@shareable.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707110653.7c49bef1@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004 11:06:53 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> But: isn't it better to have just one sysctl parameter set (tcp_rmem)
> and set the window scale as needed rather than increasing the already
> bewildering array of dials and knobs?  I can't see why it would be advantageous
> to set a window scale of 7 if the largest possible window ever offered
> is limited to a smaller value? 

Stephen, here is what is going to happen if we apply your patch.

The default window scale will be 2, which is under the value which
starts to cause the problems which is 3.

So things will silently work, and most people will not notice the
problem.

I'd much rather bugs scream out saying "I'm a bug fix me!" than to
just silently linger around mostly unnoticed.
