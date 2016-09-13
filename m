From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Tue, 13 Sep 2016 07:18:01 +0000
Message-ID: <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>,<20160913063806.GP8812@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Bloch <markb@mellanox.com>,
        Ram Amrani <Ram.Amrani@qlogic.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        David Miller <davem@davemloft.net>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Michal Kalderon <Michal.Kalderon@qlogic.com>,
        Rajesh Borundia <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0049.outbound.protection.outlook.com ([104.47.36.49]:23622
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751438AbcIMHdX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 03:33:23 -0400
In-Reply-To: <20160913063806.GP8812@leon.nu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> >> +uint debug;
>> >> +module_param(debug, uint, 0);
> >>> +MODULE_PARM_DESC(debug, "Default debug msglevel");
>>
>> >Why are you adding this as a module parameter?
>>
>>  I believe this is mostly to follow same line as qede which also defines
> > 'debug' module parameter for allowing easy user control of debug
> > prints [& specifically for probe prints, which can't be controlled
> > otherwise].

> Can you give us an example where dynamic debug and tracing infrastructure=
s
> are not enough?

> AFAIK, most of these debug module parameters are legacy copy/paste
> code which is useless in real life scenarios.

Define 'enough'; Using dynamic debug you can provide all the necessary
information and at an even better granularity that's achieved by suggested
infrastructure,  but is harder for an end-user to use. Same goes for tracin=
g.

The 'debug' option provides an easy grouping for prints related to a specif=
ic
area in the driver.
