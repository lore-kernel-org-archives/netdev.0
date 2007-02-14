From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [ipw3945-devel] [ANNOUNCE] d80211 based driver for Intel	PRO/Wireless
 3945ABG
Date: Tue, 13 Feb 2007 16:16:06 -0800
Message-ID: <45D254C6.7050401@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <20070213181313.GA5350@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070213181313.GA5350-+ZI9xUNit7I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:
...
>> You can find the new driver, and additional information 
>> about it, here:
>>
>>   http://intellinuxwireless.org/iwlwifi.
> ...
>> You can find that package at:
>>
>>   http://intellinuxwireless.org/d80211
>>
>> Ok.  Now... any questions?
> 
> Yes... is there merged .git tree somewhere? I downloaded iwl git tree,
> but it did not contain d80211 stack. I'm now downloading wireless-dev
> git tree...
> 							Pavel

There isn't a singular merged iwlwifi + d80211 package tree outside of 
wireless-dev, and iwlwifi isn't there yet (I'm cleaning out some dead 
and duplicated code before we submit)

I've put up http://intellinuxwireless.org/repos/?p=d80211.git so you can 
pull the d80211 package via git (vs. downloading the tarball).  Running 
'make patch_kernel' will then install the d80211 subsystem containing 
patches not yet in wireless-dev into your kernel sources (specified via 
KSRC=)

James
