From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Tue, 26 May 2015 10:06:17 -0700
Message-ID: <1432659977.2846.100.camel@perches.com>
References: <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
	 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
	 <1432575448.2846.63.camel@perches.com> <20150526044611.GA3465@sudip-PC>
	 <1432616108.2846.83.camel@perches.com> <20150526050212.GC3465@sudip-PC>
	 <1432616879.2846.86.camel@perches.com> <20150526141401.GC21573@kroah.com>
	 <1432651739.2846.93.camel@perches.com> <20150526163555.GA9685@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	devel@driverdev.osuosl.org,
	Sudip Mukherjee <sudip@vectorindia.org>,
	linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
	netdev@vger.kernel.org, Haggai Eran <haggai.eran@gmail.com>,
	Arek Rusniak <arek.rusi@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150526163555.GA9685@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 09:35 -0700, Greg KH wrote:
> On Tue, May 26, 2015 at 07:48:59AM -0700, Joe Perches wrote:
> > > > The main point is that patches shouldn't be applied without
> > > > being submitted to a more widely read list.
> > > 
> > > I take the blame for any problems with Outreachy patches.
> > 
> > Are you going to change any procedure associated to these
> > Outreachy patches?
> 
> 2 bugs out of 900?  Nah, I think that's good odds.
> 
> Also, the outreachy patch process would overwhelm everyone else on the
> list, it's really high volume during the application phase, I'd prefer
> it to stick with the mentors that wish to help out with the process.  If
> you and/or Dan, or anyone else wishes to help out with this, I would
> really appreciate it.  But I don't think that forcing them to post to
> the driverdevel list is a good idea.

I don't think that's necessary, but sending them to any
listed maintainer should be.

If you're collecting them, I suggest you stick them in
a separate branch, post them to your driverdev list and
cc the appropriate maintainers, wait a week, then apply
them to your main branch.

You already batch post hundreds of patches for kernel
x.y.z stable branches.  What's another few hundred?
