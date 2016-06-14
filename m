From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next v3 6/7] vmxnet3: introduce command to register
 memory region
Date: Tue, 14 Jun 2016 08:54:04 +0300
Message-ID: <CAJ3xEMgpK5n8SgEAXh-7UOea1GezkAF4g0bjdULjzKgR7hmndA@mail.gmail.com>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com> <1465869007-10822-7-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	pv-drivers@vmware.com, Guolin Yang <gyang@vmware.com>
To: Shrikrishna Khare <skhare@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465869007-10822-7-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 4:50 AM, Shrikrishna Khare <skhare@vmware.com> wrote:

> +++ b/drivers/net/vmxnet3/vmxnet3_defs.h
> @@ -81,6 +81,7 @@ enum {
>         VMXNET3_CMD_RESERVED2,
>         VMXNET3_CMD_RESERVED3,
>         VMXNET3_CMD_SET_COALESCE,
> +       VMXNET3_CMD_REGISTER_MEMREGS,
>
>         VMXNET3_CMD_FIRST_GET = 0xF00D0000,
>         VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
> @@ -668,6 +669,22 @@ struct Vmxnet3_CoalesceScheme {
>         } coalPara;
>  };
>
> +struct Vmxnet3_MemoryRegion {
> +       __le64                                  startPA;
> +       __le32                                  length;
> +       __le16                                  txQueueBits;
> +       __le16                                  rxQueueBits;
> +};


What is the use case for this command?

What's the role of the tx/rx queue bits fields?
