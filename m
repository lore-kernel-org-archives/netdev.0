From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH net-next v3 1/2] pci: Add Cavium PCI vendor id
Date: Sat, 16 May 2015 09:49:40 -0500
Message-ID: <CAErSpo4fLHEu_NOuy9CkrS9DOfSyCOkddPHEQz=pp6et8wa2AA@mail.gmail.com>
References: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com> <1431747401-20847-2-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Daney <david.daney@cavium.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Aleksey Makarov <aleksey.makarov@auriga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36221 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbEPOuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 10:50:02 -0400
Received: by qkgw4 with SMTP id w4so46979387qkg.3
        for <netdev@vger.kernel.org>; Sat, 16 May 2015 07:50:01 -0700 (PDT)
In-Reply-To: <1431747401-20847-2-git-send-email-aleksey.makarov@auriga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Aleksey,

On Fri, May 15, 2015 at 10:36 PM, Aleksey Makarov
<aleksey.makarov@auriga.com> wrote:
> Signed-off-by: Aleksey Makarov <aleksey.makarov@auriga.com>
> ---
>  include/linux/pci_ids.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
> index e63c02a..3633cc6 100644
> --- a/include/linux/pci_ids.h
> +++ b/include/linux/pci_ids.h
> @@ -2327,6 +2327,8 @@
>  #define PCI_DEVICE_ID_ALTIMA_AC9100    0x03ea
>  #define PCI_DEVICE_ID_ALTIMA_AC1003    0x03eb
>
> +#define PCI_VENDOR_ID_CAVIUM           0x177d

Please read the note at the top of include/linux/pci_ids.h.  If this
definition is used in two or more drivers, mention that in the
changelog.  Otherwise, just use the bare hex value or a private
#define in your driver.

Bjorn

>  #define PCI_VENDOR_ID_BELKIN           0x1799
>  #define PCI_DEVICE_ID_BELKIN_F5D7010V7 0x701f
>
> --
> 2.4.0
>
