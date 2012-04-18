From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: tg3 'No PHY devices' loading issue
Date: Wed, 18 Apr 2012 07:43:25 -0400
Message-ID: <20120418114325.GL19507@zod.bos.redhat.com>
References: <20120417141856.GA19507@zod.bos.redhat.com>
 <20120417185007.GA3742@mcarlson.broadcom.com>
 <20120417193908.GG19507@zod.bos.redhat.com>
 <20120417210549.GI19507@zod.bos.redhat.com>
 <4F8E77F7.3080300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>
To: Harald Hoyer <harald@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F8E77F7.3080300@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2012 at 10:14:47AM +0200, Harald Hoyer wrote:
> Am 17.04.2012 23:05, schrieb Josh Boyer:
> > So it seems my issue is basically because the initramfs isn't built with
> > the broadcom module included.  I'll have to figure out a way to teach
> > dracut what to do here, since it doesn't seem to be automatically
> > picking it up (Harald CC'd).
> > 
> > Thanks much for the very quick response from everyone.
> > 
> > josh
> 
> Ok, so we have to include all kernel/drivers/net/phy/*.ko in the initramfs?

I believe that is probably the safest and most expedient solution, yes.
Ben said the Debian initramfs tool is doing just that.

josh
