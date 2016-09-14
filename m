From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Wed, 14 Sep 2016 11:17:27 +0300
Message-ID: <fbb0eb54-da12-5766-9a79-acc0d088aca0@grimberg.me>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <317f85a5-8890-e02e-6093-876f61aed1b5@grimberg.me>
 <CY1PR0701MB133732FA8478FC0B5003D97A90F10@CY1PR0701MB1337.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CY1PR0701MB133732FA8478FC0B5003D97A90F10-UpKza+2NMNLi6bjPjkn3FE5OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> > SRQ is not part of the RFC (but we do have it and NVMF was tested
> with it).
>
>>
>
>> Nice, I have plans to make SRQs better usable for our ULPs so it'd be
>
>> good to have it.
>
> That’s good to know. Are there plans on implementing XRC?
>
> Right now it looks like none of the ULPS make use of it.

The problem with XRC is that it needs to be reflected on the
wire protocol for it to actually be useful for our ULPs. Not
sure if its worth the effort...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
