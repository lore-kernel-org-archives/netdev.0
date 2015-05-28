From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Properly size the vrss queues
Date: Thu, 28 May 2015 13:52:47 +0000
Message-ID: <BY2PR0301MB0711A3A5C1A400A54237D039A0CA0@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1432682469-15033-1-git-send-email-kys@microsoft.com>
 <20150528070613.GV11588@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150528070613.GV11588@mwanda>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Thursday, May 28, 2015 12:06 AM
> To: KY Srinivasan
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH net-next 1/1] hv_netvsc: Properly size the vrss queues
> 
> Since you're redoing this anyway.
> 
> On Tue, May 26, 2015 at 04:21:09PM -0700, K. Y. Srinivasan wrote:
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> b/drivers/net/hyperv/hyperv_net.h
> > index ddcc7f8..dd45440 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -161,6 +161,7 @@ struct netvsc_device_info {
> >  	unsigned char mac_adr[ETH_ALEN];
> >  	bool link_state;	/* 0 - link up, 1 - link down */
> >  	int  ring_size;
> > +	u32  max_num_vrss_chns;
> 
> We (Joe and I) have commented before that long names don't mix well with
> the 80 character limit.  You could just leave the "num_" out.  Almost
> all variables are numbers in C so it doesn't add anything.

Thanks Dan. Actually I sent out the revised patch yesterday and I currently don't
Have the 80 char issue. If it is ok with Dave, I will not re-spin the patch. However, I will
note this comment for future work.

K. Y
> 
> regards,
> dan carpenter
