From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [2.6 patch] net/bluetooth/: misc possible cleanups
Date: Tue, 14 Dec 2004 08:34:08 +0100
Message-ID: <1103009649.2143.65.camel@pegasus>
References: <20041214041352.GZ23151@stusta.de>
Reply-To: bluez-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, bluez-devel@lists.sf.net,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <bluez-devel-admin@lists.sourceforge.net>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041214041352.GZ23151@stusta.de>
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

> The patch below contains the following possible cleanups:
> - make needlessly global code static
> - remove the following EXPORT_SYMBOL'ed but unused functions in 
>   hci_core.c:
>   - hci_suspend_dev
>   - hci_resume_dev
>   - hci_register_cb
>   - hci_unregister_cb

these functions must stay. They have users outside the mainline kernel
that are not merged back yet. Otherwise they won't be exported ;)

> Please comment on which of these changes are correct and which conflict 
> with pending patches.

Please send a separate patch for all the RFCOMM changes, because these
conflicts with some pending patches and then it will make it easier for
me to merge them.

The rest of the changes are fine with me, but I like to see also a
separate patch for the CMTP stuff and cmtp_send_capimsg() don't need a
forward declaration. Simply move the function to another place in the
source code.

Regards

Marcel




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
