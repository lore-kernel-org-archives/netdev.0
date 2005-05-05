From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [2.6 patch] net/bluetooth/: possible cleanups
Date: Thu, 05 May 2005 15:28:30 +0200
Message-ID: <1115299710.8496.168.camel@pegasus>
References: <20050505002310.GF3593@stusta.de>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.or, maxk@qualcomm.com, bluez-devel@lists.sf.net,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050505002310.GF3593@stusta.de>
Sender: bluez-devel-admin@lists.sourceforge.net
Errors-To: bluez-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=bluez-devel>
List-Id: netdev.vger.kernel.org

Hi Adrian,

> This patch contains the following possible cleanups:
> - #ifdef HCI_DATA_DUMP the following function:
>   lib.c: bt_dump
> - #if 0 the following unused global functions:
>   - hci_core.c: hci_suspend_dev
>   - hci_core.c: hci_resume_dev
> - remove the following unneeded EXPORT_SYMBOL's:
>   - hci_core.c: hci_dev_get
>   - hci_core.c: hci_send_cmd
>   - hci_event.c: hci_si_event
> 
> Please review which of these changes do make sense and which conflict 
> with pending patches.

I like to let hci_suspend_dev() and hci_resume_dev() stay for now. No
driver uses it, but actually nobody really looked deep enough to really
understand the needs for suspend of Bluetooth devices.

The hci_dev_get(), hci_send_cmd() and hci_si_event() doesn't need to be
exported. And I think that the bt_dump() and and BT_DMP() stuff can be
removed completely.

Please redo the patch and actually it is enough to copy the bluez-devel
mailing list. I will take care of getting it back into mainline.

Regards

Marcel




-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
