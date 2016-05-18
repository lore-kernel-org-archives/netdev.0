From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: [1/1] net: pegasus: remove dead coding
Date: Wed, 18 May 2016 10:50:45 +0300
Message-ID: <20160518075045.GC4388@p310>
References: <1463530410-12772-1-git-send-email-xypron.glpk@gmx.de>
 <20160518063024.GA29326@roeck-us.net>
 <1463555740.22748.0.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Petko Manolov <petkan@nucleusys.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463555740.22748.0.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-05-18 09:15:40, Oliver Neukum wrote:
> On Tue, 2016-05-17 at 23:30 -0700, Guenter Roeck wrote:
> > On Wed, May 18, 2016 at 02:13:30AM +0200, Heinrich Schuchardt wrote:
> > > (!count || count < 4) is always true.
> > 
> > Even if count >= 4 ?
> 
> The check for !count is redundant, though. Gcc, however,
> will surely simplify the expression.

Yep, gcc-6 generates this code:

	...
	cmp	$0x3,%edx
	jle	b9 <read_bulk_callback+0x69>
	...

Which does not invalidate your statement that "!count" is redundant. :)


		Petko
