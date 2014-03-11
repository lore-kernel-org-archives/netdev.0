From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] vmxnet3: fix netpoll race condition
Date: Tue, 11 Mar 2014 16:08:34 -0400
Message-ID: <20140311200834.GA2630@hmsreliant.think-freely.org>
References: <1394227527-31082-1-git-send-email-nhorman@tuxdriver.com>
 <1394448955-19915-1-git-send-email-nhorman@tuxdriver.com>
 <20140311.131615.1099547048239011196.davem@davemloft.net>
 <382556580.40955263.1394562248901.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	pv-drivers@vmware.com, stable@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <382556580.40955263.1394562248901.JavaMail.root@vmware.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 11, 2014 at 11:24:08AM -0700, Shreyas Bhatewara wrote:
> > > The fix is to do as other drivers do, and have the poll controller call the
> > > top
> > > half interrupt handler, which schedules a napi poll properly to recieve
> > > frames
> > > 
> > > Tested by myself, successfully.
> > > 
> > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > 
> > VMware folks, please review
> > 
> Neil, thanks for the updated change. It looks good.
> 
> Reviewed-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
> 
Thanks guys!
Neil
