From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Fri, 09 Feb 2007 14:45:22 -0800
Message-ID: <45CCF982.6090207@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <1171061021.7039.7.camel@dv>	 <45CCF318.2020503@linux.intel.com> <1171063040.7039.16.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1171063040.7039.16.camel@dv>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pavel Roskin wrote:
> On Fri, 2007-02-09 at 14:18 -0800, James Ketrenos wrote:
>>> grep: /lib/modules/2.6.20/build//include/linux/netdevice.h: No such file
>>> or directory
...
>> I'll look into it.  Does it work if you explicitly set KSRC to point to 
>> your kernel sources?
>>
>> $ make KSRC=/lib/modules/2.6.20/source
> 
> That works.  At least it doesn't report errors.  But it doesn't create a
> single object file.

'make' builds a set of sources compatible with the running kernel (or 
the one pointed to via KSRC=).

'make patch_kernel' will then install the sources into your kernel tree. 
  You then build d80211 as part of your main kernel (either as a module 
or static)  The changes 'patch_kernel' makes do not require a full 
kernel rebuild (you can just build the 80211 modules).

We'll want to add the ability to build as out-of-tree .ko's (similar to 
what iwlwifi does) but I wanted to get the project announced.

> "build" is still hardcoded in iwlwifi's Makefile.  It's interesting that
> D80211_INC is defined twice in Makefile.  That must be wrong.

Now that you point it out, I hadn't tried using KSRC w/ the iwlwifi 
build, just d80211.  I'll have to fix that :)

Thanks,
James
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
