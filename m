From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH] SIW: Module initialization
Date: Tue, 5 Oct 2010 10:24:26 -0600
Message-ID: <20101005162426.GB5967@obsidianresearch.com>
References: <1286261640-5121-1-git-send-email-bmt@zurich.ibm.com> <AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN@mail.gmail.com> <OFFB26426A.EB2C13FD-ONC12577B3.00488392-C12577B3.004895E4@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>, bart.vanassche-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <OFFB26426A.EB2C13FD-ONC12577B3.00488392-C12577B3.004895E4-Xeyd2O9EBijQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2010 at 03:12:48PM +0200, Bernard Metzler wrote:

> good point. do you have a suggestion here - would you like to see 
> siw to be enabled more selectively? 
> iwarp is a protocol on top of TCP, explicitly defining the 
> semantics of data fetching and placement. end-to-end connectivity 
> and efficient data shipping is provided by TCP/IP. not taking into 
> account dedicated RDMA hardware, any TCP stream may carry iwarp 
> traffic. from that point of view, binding a software based 
> rdma stack to dedicated devices is a concession to the 
> given environment, in particular to the given rdma 
> connection management. therefore, we started with binding to all 
> available network devices. 

Considering the possibility for security issues with code like this it
would be much nicer to have an 'opt in' mechanism.. Ie a
 /sys/class/net/eth0/enable_iwarp
type of file.. You can track the add/remove of netdevices weth netevents.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
