From: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 13 Sep 2016 08:44:06 +0000
Message-ID: <DM3PR1101MB1181DF570D4F01A0CEB1CFC7E2FE0@DM3PR1101MB1181.namprd11.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912180508.GI5843@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160912180508.GI5843-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jason,
I see that "include/uapi/rdma" contains API that is common.
The qedr_user.h, that I assume you are referring to, is a qedr specific API=
.
For example, we issue the ib_copy_to_udata() on structures defined in the f=
ile.
So per my understanding it is in place.

Thanks,
Ram


-----Original Message-----
From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]=20
Sent: Monday, September 12, 2016 9:05 PM
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>; Yuval Mintz <Y=
uval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Michal Kalder=
on <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Rajesh Borundia <rajesh.borundia-h88ZbnxC6KBhl2p70BpVqQ@public.gmane.org=
m>; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC

On Mon, Sep 12, 2016 at 07:07:34PM +0300, Ram Amrani wrote:
>  drivers/infiniband/hw/qedr/main.c              |  907 ++++++
>  drivers/infiniband/hw/qedr/qedr.h              |  494 ++++
>  drivers/infiniband/hw/qedr/qedr_cm.c           |  626 +++++
>  drivers/infiniband/hw/qedr/qedr_cm.h           |   61 +
>  drivers/infiniband/hw/qedr/qedr_hsi.h          |   56 +
>  drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  748 +++++
>  drivers/infiniband/hw/qedr/qedr_user.h         |   80 +

We are requiring new uAPI headers are placed under include/uapi/rdma/, plea=
se coordinate with Leon on the path.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
