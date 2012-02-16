From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Thu, 16 Feb 2012 15:39:05 +0100
Message-ID: <1329403145.3915.10.camel@jlt3.sipsolutions.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	 <1326621743.3448.1.camel@jlt3.sipsolutions.net>
	 <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
	 ( sfid-20120115_163411_716244_29DE7A13) <1326704259.3510.3.camel@jlt3.sipsolutions.net>
	 <4F3CF0C1.3090304@broadcom.com>
	 <1329395881.3915.7.camel@jlt3.sipsolutions.net>
	 <4F3D0012.9070808@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F3D0012.9070808-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-16 at 14:09 +0100, Arend van Spriel wrote:


> > When the firmware loading fails, the driver should unbind from the
> > device that it failed for, and the retrying behaviour doesn't change
> > (and requires a rebind)

> That helps. My driver was happily bound to the device until unloading 
> the driver or unplugging the device.

Right, if it fails you should call device_release_driver()

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
