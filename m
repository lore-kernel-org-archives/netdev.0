From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC] Bluetooth: Add ACL MTU, available buffers and total buffers to hci_conn_info.
Date: Fri, 6 Jun 2014 12:44:55 +0200
Message-ID: <39777AAC-6DB7-444D-9137-BCDDE99DA781@holtmann.org>
References: <1402049880-7686-1-git-send-email-kiran.kumar@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nick Pelly <npelly-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Kiran Kumar Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1402049880-7686-1-git-send-email-kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kiran,

> Add ACL MTU, available buffers and total buffers to hci_conn_info.
> 
> This provides userspace debugging tools access to ACL flow control state.
> 
> This is one of the number of patches from the Android AOSP common.git tree,
> which is used on almost all Android devices.  so I wanted to submit it for
> review to see if it should go upstream.
> 
> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
> Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Signed-off-by: Nick Pelly <npelly-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> [kiran: Added context to commit message]
> Signed-off-by: Kiran Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
> include/net/bluetooth/hci.h |  3 +++
> net/bluetooth/hci_conn.c    | 18 ++++++++++++++++++
> 2 files changed, 21 insertions(+)

this would break existing API and can not be accepted. NAK.

Regards

Marcel
