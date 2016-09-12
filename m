From: Parav Pandit <pandit.parav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Mon, 12 Sep 2016 22:19:18 +0530
Message-ID: <CAG53R5UqF21z34jB2HJCTXU8w3Kbj_Jon=wBAoO5tYSqbD1f6g@mail.gmail.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com> <20160912163928.GK8812@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160912163928.GK8812-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 10:09 PM, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Sep 12, 2016 at 07:07:34PM +0300, Ram Amrani wrote:
>
>>  include/linux/qed/common_hsi.h                 |    1 +
>>  include/linux/qed/qed_if.h                     |    9 +-
>>  include/linux/qed/qed_ll2_if.h                 |  140 +
>>  include/linux/qed/qed_roce_if.h                |  604 ++++
>>  include/linux/qed/qede_roce.h                  |   88 +
>>  include/linux/qed/rdma_common.h                |    1 +
>
> Something not directly related to your patches, but they brought my
> attention to the fact that all these new (and old) rdma<->net devices
> are polluting include/linux
>
ocrdma driver includes be_roce.h located in net/ethernet/emulex/benet
location instead of include/linux/.
This file helps to bind rdma to net device or underlying hw device.

May be similar change can be done for rest of the drivers for
rdma<-->net devices?


> Filtered output:
> =E2=9E=9C  linux-rdma git:(topic/fixes-for-4.8-2) ls -dl include/linux/*/
> drwxrwxr-x  2 leonro leonro  4096 Aug 30 16:27 include/linux/hsi/
> drwxrwxr-x  2 leonro leonro  4096 Sep 12 19:08 include/linux/mlx4/
> drwxrwxr-x  2 leonro leonro  4096 Sep  7 15:31 include/linux/mlx5/
> drwxrwxr-x  2 leonro leonro  4096 Sep  8 17:46 include/linux/qed/
>
> Is this the right place for them?
>
> Thanks
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
