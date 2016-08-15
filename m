From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: Re: [PATCH 1/1] Bluetooth: add printf format attribute to
 hci_set_[fh]w_info()
Date: Mon, 15 Aug 2016 10:00:46 +0200
Message-ID: <2def3cf7-e2a4-0e08-ffc6-b5d9f633778b@m4x.org>
References: <20160729112825.22091-1-nicolas.iooss_linux@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160729112825.22091-1-nicolas.iooss_linux@m4x.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
After I sent the following patch a few weeks ago, I have not received
any feedback. Could you please review it?

Thanks,
Nicolas

On 29/07/16 13:28, Nicolas Iooss wrote:
> Commit 5177a83827cd ("Bluetooth: Add debugfs fields for hardware and
> firmware info") introduced hci_set_hw_info() and hci_set_fw_info().
> These functions use kvasprintf_const() but are not marked with a
> __printf attribute.  Adding such an attribute helps detecting issues
> related to printf-formatting at build time.
> 
> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
> ---
>  include/net/bluetooth/hci_core.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
> index ee7fc47680a1..012e5031fe47 100644
> --- a/include/net/bluetooth/hci_core.h
> +++ b/include/net/bluetooth/hci_core.h
> @@ -1026,8 +1026,8 @@ int hci_resume_dev(struct hci_dev *hdev);
>  int hci_reset_dev(struct hci_dev *hdev);
>  int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb);
>  int hci_recv_diag(struct hci_dev *hdev, struct sk_buff *skb);
> -void hci_set_hw_info(struct hci_dev *hdev, const char *fmt, ...);
> -void hci_set_fw_info(struct hci_dev *hdev, const char *fmt, ...);
> +__printf(2, 3) void hci_set_hw_info(struct hci_dev *hdev, const char *fmt, ...);
> +__printf(2, 3) void hci_set_fw_info(struct hci_dev *hdev, const char *fmt, ...);
>  int hci_dev_open(__u16 dev);
>  int hci_dev_close(__u16 dev);
>  int hci_dev_do_close(struct hci_dev *hdev);
> 
