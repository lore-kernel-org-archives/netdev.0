From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [PATCH v2 1/3] net: Add support for hardware-offloaded encapsulation
Date: Mon, 12 Nov 2012 14:31:05 +0200
Message-ID: <CAMAG_ecK1eUEcCD49DxSzCEqEHwd8qzJPvs3uK+FBW2MMwkV8w@mail.gmail.com>
References: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com> <1352709418-28996-2-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352709418-28996-2-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index 5ac3212..6dd59a5 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h

>         NETIF_F_RXCSUM_BIT,             /* Receive checksumming offload */
> +       NETIF_F_RXCSUM_ENC_BIT,         /* Receive checksuming offload */
> +                                       /* for encapsulation */
in the future more features will be needed for tunneled packets (tso,
rxhash, etc..)
so I think it would make sense to add a new features variable for
tunneled packets, and the enum above will be used as is.
for example, if the driver supports checksum offloading for
encapsulated packets, then it will set the RXCSUM_BIT in that
variable:
netdev->encap_hw_features = NETIF_F_RXCSUM_BIT;
saeed
