From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Wed, 20 May 2015 10:40:37 +0200
Message-ID: <1432111237.8287.3.camel@suse.com>
References: <s5hwq04zypv.wl-tiwai@suse.de>
	 <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
	 <s5hpp5wtrrp.wl-tiwai@suse.de> <1432057375.3970.4.camel@suse.com>
	 <s5h7fs3u5gy.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Laura Abbott <labbott@redhat.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5h7fs3u5gy.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-20 at 08:29 +0200, Takashi Iwai wrote:
> The data is cached in RAM.  More specifically, the former loaded
> firmware files are reloaded and saved at suspend for each device
> object.  See fw_pm_notify() in firmware_class.c.

OK, this may be a stupid idea, but do we know the firmware
was successfully loaded in the first place?
Also btusb is in the habit of falling back to a generic
firmware in some places. It seems to me that caching
firmware is conceptually not enough, but we'd also need
to record the absence of firmware images.

	Regards
		Oliver
