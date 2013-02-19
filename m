From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 15:10:26 +0100
Message-ID: <20130219141026.GB26748@pd.tnic>
References: <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
 <20130219131500.GW23197@arwen.pp.htv.fi>
 <20130219132853.GG26623@pd.tnic>
 <20130219133809.GA4390@arwen.pp.htv.fi>
 <20130219135056.GH26623@pd.tnic>
 <512384EF.9020602@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Felipe Balbi <balbi@ti.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:60465 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932921Ab3BSOKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 09:10:30 -0500
Content-Disposition: inline
In-Reply-To: <512384EF.9020602@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 02:58:07PM +0100, Hannes Reinecke wrote:
> Please consider adding a default attribute which return '-EINVAL' or
> somesuch when the function pointers are not set. But _not_ adding it
> via device_create_file(). That's evil.

This is what we do now. We probably could add the permissions fiddling
out in the the code but remain using DEVICE_ATTR.

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
