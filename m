From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [RFC 07/11] Add support for memory registeration verbs
Date: Tue, 13 Sep 2016 17:26:24 +0300
Message-ID: <dfff3b6a-07da-38eb-e844-a48f713ff0f7@grimberg.me>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696465-27986-8-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> +static inline struct qedr_ah *get_qedr_ah(struct ib_ah *ibah)
> +{
> +	return container_of(ibah, struct qedr_ah, ibah);
> +}

Little surprising to find that here... how is the ah related
to this patch?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
