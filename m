From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 15:50:43 +0100
Message-ID: <20130219145043.GJ26623@pd.tnic>
References: <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
 <20130219131500.GW23197@arwen.pp.htv.fi>
 <20130219132853.GG26623@pd.tnic>
 <20130219133809.GA4390@arwen.pp.htv.fi>
 <20130219135056.GH26623@pd.tnic>
 <20130219113521.510db290@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Felipe Balbi <balbi@ti.com>, Greg KH <gregkh@linuxfoundation.org>,
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
In-Reply-To: <20130219113521.510db290@redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2013 at 11:35:21AM -0300, Mauro Carvalho Chehab wrote:
> That's covers everything but Hannes arguments. I don't think that
> adding just one more device_create_file() on a driver that creates
> dozens (or hundreds) of sys nodes, depending on the number of DIMMS
> on the system would make it any worse.

Right, those attributes are created once during EDAC core init and we
haven't seen any issues so far so let's not address this just yet but
make a mental note about the race condition possibility.

> [PATCH EDAC] edac: only create sdram_scrub_rate where supported
> 
> Currently, sdram_scrub_rate sysfs node is created even if the device
> doesn't support get/set the scub rate. Change the logic to only
> create this device node when the operation is supported.
> 
> Reported-by: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Mauro Carvalho Chehab <mchehab@redhat.com>

Acked-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
