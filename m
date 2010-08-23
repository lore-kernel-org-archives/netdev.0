From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v4 0/2] Get and Set Feature Reports on HIDRAW (USB and
 Bluetooth)
Date: Mon, 23 Aug 2010 15:00:14 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1008231459370.1019@pobox.suse.cz>
References: <1281442367.12579.206.camel@localhost.localdomain> <1281990059-3562-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stefan Achatz <erazor_de@users.sourceforge.net>,
	Antonio Ospite <ospite@studenti.unina.it>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephane Chatty <chatty@enac.fr>,
	Michael Poole <mdpoole@troilus.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1281990059-3562-1-git-send-email-alan@signal11.us>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2010, Alan Ott wrote:

> This is version 4. Built against 2.6.35+ revision 320b2b8de12698 .
> 
> Alan Ott (2):
>   HID: Add Support for Setting and Getting Feature Reports from hidraw
>   Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and
>     HIDIOCSFEATURE
> 
>  drivers/hid/hidraw.c          |  105 ++++++++++++++++++++++++++++++++++++--
>  drivers/hid/usbhid/hid-core.c |   37 +++++++++++++-
>  include/linux/hid.h           |    3 +
>  include/linux/hidraw.h        |    3 +
>  net/bluetooth/hidp/core.c     |  114 +++++++++++++++++++++++++++++++++++++++--
>  net/bluetooth/hidp/hidp.h     |    8 +++
>  6 files changed, 260 insertions(+), 10 deletions(-)

Marcel, as per our previous discussion -- what is your word on this? I'd 
be glad taking it once you Ack the bluetooth bits (which, as far as I 
understood from your last mail, don't have strong objections against any 
more).

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
