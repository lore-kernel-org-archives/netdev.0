From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 23:44:05 +0100
Message-ID: <20130218224405.GB21493@pd.tnic>
References: <20130218171334.GA31329@kroah.com>
 <20130218172700.GH2663@arwen.pp.htv.fi>
 <20130218174916.GA2070@kroah.com>
 <20130218184633.GC10755@arwen.pp.htv.fi>
 <20130218164638.7cb53baa@redhat.com>
 <20130218200542.GB20137@arwen.pp.htv.fi>
 <20130218184742.5a4c3c06@redhat.com>
 <20130218215434.GB16794@kroah.com>
 <20130218221306.GA21493@pd.tnic>
 <20130218222618.GA21818@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>, balbi@ti.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130218222618.GA21818@kroah.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 18, 2013 at 02:26:18PM -0800, Greg KH wrote:
> I don't know, it depends on if userspace can handle this properly or
> not. What tools rely on this sysfs file? WHat happens when they get a
> non-number in the file?

I'm not aware of any, frankly speaking.

If there are any, those tools should be able to handle the -ENODEV
they get. Now, if this gets changed this way, the read would succeed
but they'll have to parse the returned value and see that it is not an
integer.

So I don't know either.

But my gut feeling says to stay concervative and not touch this code -
we don't know what uses it and how much we would break by "fixing" it.
The current situation is not that big of a deal IMVHO and I'd be willing
to accept the small inconcistency versus possibly breaking userspace.

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
