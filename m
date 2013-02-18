From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 13:54:34 -0800
Message-ID: <20130218215434.GB16794@kroah.com>
References: <20130218153316.GA2663@arwen.pp.htv.fi>
 <20130218155012.GA30974@kroah.com>
 <20130218155215.GB2663@arwen.pp.htv.fi>
 <20130218171334.GA31329@kroah.com>
 <20130218172700.GH2663@arwen.pp.htv.fi>
 <20130218174916.GA2070@kroah.com>
 <20130218184633.GC10755@arwen.pp.htv.fi>
 <20130218164638.7cb53baa@redhat.com>
 <20130218200542.GB20137@arwen.pp.htv.fi>
 <20130218184742.5a4c3c06@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: balbi@ti.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130218184742.5a4c3c06@redhat.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 18, 2013 at 06:47:42PM -0300, Mauro Carvalho Chehab wrote:
> In the past, the sysfs node creation was done using the raw sysfs support.
> Doing dynamic creation with the old code were much more complex. I guess
> that's the reason why the code was written this way. Now that the code 
> uses struct device, it shouldn't be hard to change the code to only 
> create this attribute if the device has support for scrub rate setting.
> 
> Yet, that would change the userspace API. I'm not sure what
> applications would rely on the current behavior. So, changing it
> would require some investigation in order to avoid regressions.

Because sysfs is "one value per file" the lack of a file showing up
shouldn't cause any userspace tools any problems, that is why we did
things this way.

But, of course, userspace programmers do know how to mess things up...

greg k-h
