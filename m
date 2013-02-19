From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 14:55:00 +0100
Message-ID: <20130219135500.GI26623@pd.tnic>
References: <20130219081149.46972f56@redhat.com>
 <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
 <20130219131500.GW23197@arwen.pp.htv.fi>
 <20130219132853.GG26623@pd.tnic>
 <20130219133809.GA4390@arwen.pp.htv.fi>
 <20130219105048.198e2cfd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: balbi@ti.com, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130219105048.198e2cfd@redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2013 at 10:50:48AM -0300, Mauro Carvalho Chehab wrote:
> It is actually worse, as if someone is using a C code to open the device
> with
> 	fp = open ("/sys/devices/system/edac/mc/mc0/sdram_scrub_rate", O_RDWR);
> 
> It will now start to fail if the device doesn't have both permissions.

That's fine - you're supposed to handle open()'s retval properly anyway. See my
other mail.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
