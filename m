From: Tim Berti <tim@tsearch.com>
Subject: RE: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 13:35:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <828E111C7AEF60468FAA5FBC696DD80F67DF37@64-3-142-15.dia.xo.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

How do i get off this list?

Tim Berti 
Senior Recruiter 
TECHNOLOGY SEARCH INTERNATIONAL 
1737 North First Street, Suite 600 
San Jose, CA. 95112 
http://www.tsearch.com 
Email: tim@tsearch.com 
Phone: 408-437-9500 Ext. 303 



-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org]
Sent: Tuesday, July 06, 2004 1:37 PM
To: David S. Miller
Cc: jamie@shareable.org; netdev@oss.sgi.com; linux-net@vger.kernel.org;
linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fix tcp_default_win_scale.


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
