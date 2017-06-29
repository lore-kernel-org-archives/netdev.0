From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Add sockaddr length checks before accessing
 sa_family in bind and connect handlers
Date: Thu, 29 Jun 2017 14:38:34 +0200
Message-ID: <838A10A8-41D2-41B4-BAAD-BD8FFE84260D@holtmann.org>
References: <20170629120459.16937-1-mjurczyk@google.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170629120459.16937-1-mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Mateusz,

> Verify that the caller-provided sockaddr structure is large enough to
> contain the sa_family field, before accessing it in bind() and connect()
> handlers of the Bluetooth sockets. Since neither syscall enforces a minimum
> size of the corresponding memory region, very short sockaddrs (zero or one
> byte long) result in operating on uninitialized memory while referencing
> sa_family.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
> net/bluetooth/l2cap_sock.c  | 5 +++--
> net/bluetooth/rfcomm/sock.c | 3 ++-
> net/bluetooth/sco.c         | 6 ++----
> 3 files changed, 7 insertions(+), 7 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
