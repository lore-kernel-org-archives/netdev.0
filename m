From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH V2] bluetooth: btusb: Fix issue with suspend
Date: Mon, 8 Sep 2014 18:25:27 -0700
Message-ID: <EE5EAEAA-DA2E-4B0D-B961-8819F958E052@holtmann.org>
References: <1410030368-23289-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410030368-23289-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Larry,

> Suspend could fail for some platforms because
> btusb_suspend==> btusb_stop_traffic ==> usb_kill_anchored_urbs,
> 
> When btusb_bulk_complete returns before system suspend and resubmits an urb,
> the system cannot enter suspend state.
> 
> Signed-off-by: Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
> V2 - Fix incorrect test as noted by Marcel.
> 
> ---
> Johan,
> 
> To help Champion with the process, I have formatted the patch in
> the correct manner. I hope I understand the issue correctly and
> stated it in a coherent manner in the commit message.
> 
> Larry
> ---
> drivers/bluetooth/btusb.c | 9 +++++++++
> 1 file changed, 9 insertions(+)

patch has been applied to bluetooth-next tree.

Regards

Marcel
