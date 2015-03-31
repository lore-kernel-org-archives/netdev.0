From: Robert Dolca <robert.dolca-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [linux-nfc] [PATCH 3/8] NFC: NCI: Adds NCI init and reset API for drivers
Date: Tue, 31 Mar 2015 17:05:53 +0300
Message-ID: <CAFPB+YcvZReLRsv5dYh=jTwASa1vo-0pK5T1AS-eGmzO=arDLQ@mail.gmail.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-4-git-send-email-robert.dolca@intel.com> <20150326002937.GB10954@ribalta.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150326002937.GB10954-41CF7WKNp/H9zxVx7UNMDg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2015 at 2:29 AM, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> Hi Robert,
>
> On Tue, Feb 24, 2015 at 12:01:47PM +0200, Robert Dolca wrote:
>> In order to communicate with the device during the setup
>> phase, the driver may need to initialize the device. After
>> the setup is done the driver should reset the device to leave
>> it in the same state that it was before the setup function
>> call.
> I would prefer not to export those symbols, but instead introduce a
> quirk bitmap to let the NCI core know that your device expects the core
> to be initialized before calling the setup ops.
> That would be done from nci_open_device().

As part of the initialization / firmware upgrade procedure the driver
needs to reset and initialize the NCI connection multiple times.
Having the connection initialized before calling setup is not enough.

Regards,
Robert
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
