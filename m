From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 3/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:33:00 -0700
Message-ID: <CAL1RGDWmz4Yr8mqWMywN9X+refDEJ4W=ieBvOtZZc32qMDA5_w@mail.gmail.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <339d9e05-38fd-45b1-83ed-f06277bd1326@exht1.ad.emulex.com>
 <CAL1RGDWnc478=ToFQEC51Usn6LLZgLen=CymFZ0C0GnRp9BAsw@mail.gmail.com> <88B766C272F2C64B944B21AD078333151C964A63F1@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <88B766C272F2C64B944B21AD078333151C964A63F1-/SwythR3zqxVRK6PHKByhFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2012 at 12:04 PM,  <Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org> wrote:
>> > +/* mailbox cmd response */
>> > +struct ocrdma_mbx_rsp {
>> > + =A0 =A0 =A0 u32 subsys_op;
>> > + =A0 =A0 =A0 u32 status;
>> > + =A0 =A0 =A0 u32 rsp_len;
>> > + =A0 =A0 =A0 u32 add_rsp_len;
>> > +} __packed;

>> ...similar comments about only using __packed where you really need =
it...

> This pack is required as it is shared with hardware and need to be of=
 16 bytes for 32 and 64 bit architecture. Do not wanted to take risk of=
 different compiler versions. So keeping it packed.

I really think if you can't trust your compiler to lay this structure
out properly,
you have a lot of bigger problems.  But whatever, it's not a big deal.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
