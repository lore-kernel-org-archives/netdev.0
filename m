From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCHv2 3/7] TAP: Tap character device creation/destroy API
Date: Thu, 19 Jan 2017 23:33:49 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F28C6D4CF@ORSMSX113.amr.corp.intel.com>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
        <1484697786-50323-4-git-send-email-sainath.grandhi@intel.com>
 <20170118.162647.1034141344569503382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mahesh@bandewar.net" <mahesh@bandewar.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118.162647.1034141344569503382.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, January 18, 2017 1:27 PM
> To: Grandhi, Sainath <sainath.grandhi@intel.com>
> Cc: netdev@vger.kernel.org; mahesh@bandewar.net; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCHv2 3/7] TAP: Tap character device creation/destroy API
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> Date: Tue, 17 Jan 2017 16:03:02 -0800
> 
> > +int tap_create_cdev(struct cdev *tap_cdev,
> > +		    dev_t *tap_major, const char *device_name) {
> > +	int err;
> > +
> > +	err = alloc_chrdev_region(tap_major, 0, TAP_NUM_DEVS,
> device_name);
> > +
> > +	if (err)
> > +		goto out1;
> 
> No need to have an empty line between the alloc_chrdev_region() call and
> the "if (err)" test.
> 
> > diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h index
> > d887aaa..a2dfd90 100644
> > --- a/include/linux/if_tap.h
> > +++ b/include/linux/if_tap.h
> > @@ -10,7 +10,7 @@ struct file;
> >  struct socket;
> >  static inline struct socket *tap_get_socket(struct file *f)  {
> > -        return ERR_PTR(-EINVAL);
> > +	return ERR_PTR(-EINVAL);
> >  }
> 
> Instead of having to fix up the indentation here, get it right in the first place in
> patch #2.

Will work on these two comments in next version.
