From: "David S. Miller" <davem@redhat.com>
Subject: Re: netdev_ops?
Date: Wed, 23 Jul 2003 01:15:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723011551.5663a020.davem@redhat.com>
References: <3F1E17BC.30100@candelatech.com>
	<20030722220745.379a73c6.davem@redhat.com>
	<3F1E1D62.90009@candelatech.com>
	<20030722230215.284dd270.davem@redhat.com>
	<3F1E2A00.5080506@candelatech.com>
	<20030722232719.216d7823.davem@redhat.com>
	<3F1E2CE9.2080404@candelatech.com>
	<20030723000130.3a6a917e.davem@redhat.com>
	<3F1E391B.80209@candelatech.com>
	<20030723003439.684de751.davem@redhat.com>
	<3F1E4290.6020303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F1E4290.6020303@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 01:08:48 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Is it their choice to participate in the /proc/net/dev output?

Precisely yes, this is why they have the option of not
providing the ->get_stats() method by leaving it set
to NULL.

> > My final note:  You don't even have the problem you claim to have.
> >                 Use your brain and 'grep' a little bit, ok? :-)
> > 
> >                 egrep get_stats net/core/rtnetlink.c
> > 
> >                 There it is, exactly what you need and supported on
> >                 every single kernel out there.
> 
> Yep, I looked through that..and through libnetlink, and the complexity
> is not worth it.

Nice cop out.

Netlink is the standard method to obtain information about
network device, address, and route information.  It is even
defined by an RFC.

We're not going to add a hack to the kernel just because you
think netlink is too complex.  If it's too complex, you get
to live with the text based output.

I'll tell you this, the netlink version will work on more systems,
even ones that don't have /proc mounted.

Your patch duplicates existing functionality (getting network
statistics in binary form), so just based upon that I cannot allow
your patch.
