From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 13:36:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706133641.4a58af30@dell_ss3.pdx.osdl.net>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
	<20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
	<20040706194034.GA11021@mail.shareable.org>
	<20040706130549.31daa8e0@dell_ss3.pdx.osdl.net>
	<20040706132822.70c8174a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamie@shareable.org, netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040706132822.70c8174a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 13:28:22 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 6 Jul 2004 13:05:49 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > On Tue, 6 Jul 2004 20:40:34 +0100
> > Jamie Lokier <jamie@shareable.org> wrote:
> > 
> > > Are you saying there are broken firewalls which strip TCP options in
> > > one direction only?
> > 
> > It appears so.
> 
> Ok, this is a possibility.  And why it breaks is that if the ACK
> for the SYN+ACK comes back, the SYN+ACK sender can only assume
> that the window scale was accepted.
> 
> Stephen, do you have a trace showing exactly this?

No, I don't have a br0ken firewall here.  I can get out fine.
When I setup with same kernel as packages.gentoo.org, it works fine as well.
