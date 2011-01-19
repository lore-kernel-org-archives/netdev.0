From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v5 0/4] Adding HID Feature Report Support to hidraw
Date: Wed, 19 Jan 2011 13:17:00 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101191316230.26685@pobox.suse.cz>
References: <1295337880-12452-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Poole <mdpoole@troilus.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>, Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1295337880-12452-1-git-send-email-alan@signal11.us>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2011, Alan Ott wrote:

> This patch adds Feature Report support for USB and Bluetooth HID devices
> through hidraw.
> 
> The first two patches prepare the bluetooth side for the change.
> 	a. Make sure the hidp_session() thread is started before
> 	   device's probe() functions are called.
> 	b. Wait for ACK/NAK on sent reports, and return proper
> 	   error codes.
> The third patch is the hidraw core and USB changes.
> The fourth patch is the Bluetooth changes.
> 
> Thanks to Antonio Ospite and Bill Good for providing testing and feedback.
> 
> 
> Alan Ott (4):
>   bt hidp: Move hid_add_device() call to after hidp_session() has
>     started.
>   bt hidp: Wait for ACK on Sent Reports
>   HID: Add Support for Setting and Getting Feature Reports from hidraw
>   Bluetooth hidp: Add support for hidraw HIDIOCGFEATURE and
>     HIDIOCSFEATURE
> 
>  drivers/hid/hidraw.c          |  106 +++++++++++++++++++-
>  drivers/hid/usbhid/hid-core.c |   35 +++++++
>  include/linux/hid.h           |    3 +
>  include/linux/hidraw.h        |    3 +
>  net/bluetooth/hidp/core.c     |  214 ++++++++++++++++++++++++++++++++++++++---
>  net/bluetooth/hidp/hidp.h     |   15 +++

Before proceeding with these patches, I'd really like to have comment 
(ideally 'Acked-by') from Marcel on the net/bluetooth/hidp part, 
obviously.

Marcel?

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
