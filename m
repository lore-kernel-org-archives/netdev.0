From: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Mon, 12 Sep 2016 19:17:35 +0000
Message-ID: <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>,<516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <516b98c7-477a-4890-0d92-529dc32f2c4e-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> +uint debug;
>> +module_param(debug, uint, 0);
>> +MODULE_PARM_DESC(debug, "Default debug msglevel");

>Why are you adding this as a module parameter?=20

I believe this is mostly to follow same line as qede which also defines
'debug' module parameter for allowing easy user control of debug
prints [& specifically for probe prints, which can't be controlled
otherwise].
     =
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
