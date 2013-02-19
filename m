From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 14:28:54 +0100
Message-ID: <20130219132853.GG26623@pd.tnic>
References: <20130218224405.GB21493@pd.tnic>
 <20130219070310.2cadad7a@redhat.com>
 <20130219101121.GJ23197@arwen.pp.htv.fi>
 <20130219081149.46972f56@redhat.com>
 <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
 <20130219131500.GW23197@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130219131500.GW23197@arwen.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2013 at 03:15:00PM +0200, Felipe Balbi wrote:
> what's the problem with that ?

Not a problem - simply annoying.

$ ./test.sh
cat: /path/to/file/that/doesnt/exist.txt: No such file or directory
Setting scrubrate to:

I'm sure someone would ask themselves why all of a sudden the file is
gone.

> $ cat /path/to/file/that/doesnt/exist.txt
> cat: /path/to/file/that/doesnt/exist.txt: No such file or directory
> 
> Didn't see any gates to hell opening here...

And I don't see why we have to debate such a trivial thing when we can
fix it *properly* without *absolutely* *not* upsetting userspace.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
