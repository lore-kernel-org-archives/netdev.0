From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 3/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 09:26:06 -0700
Message-ID: <CAL1RGDWnc478=ToFQEC51Usn6LLZgLen=CymFZ0C0GnRp9BAsw@mail.gmail.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com> <339d9e05-38fd-45b1-83ed-f06277bd1326@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <339d9e05-38fd-45b1-83ed-f06277bd1326-nbYkmrCdWxmgMrCBcu8zE0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +/* mailbox cmd response */
> +struct ocrdma_mbx_rsp {
> + =A0 =A0 =A0 u32 subsys_op;
> + =A0 =A0 =A0 u32 status;
> + =A0 =A0 =A0 u32 rsp_len;
> + =A0 =A0 =A0 u32 add_rsp_len;
> +} __packed;

=2E..similar comments about only using __packed where you really need i=
t...

> +#define is_cqe_valid(cq, cqe) \
> + =A0 =A0 =A0 (((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_V=
ALID)\
> + =A0 =A0 =A0 =3D=3D cq->phase) ? 1 : 0)
> +#define is_cqe_for_sq(cqe) \
> + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_QT=
YPE) ? 0 : 1)
> +#define is_cqe_for_rq(cqe) \
> + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_QT=
YPE) ? 1 : 0)
> +#define is_cqe_invalidated(cqe) \
> + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_IN=
VALIDATE) ? \
> + =A0 =A0 =A0 1 : 0)
> +#define is_cqe_imm(cqe) \
> + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_IM=
M) ? 1 : 0)
> +#define is_cqe_wr_imm(cqe) \
> + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_WR=
ITE_IMM) ? 1 : 0)

=2E..similar comment about using readable typesafe inline functions
instead of macros...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
