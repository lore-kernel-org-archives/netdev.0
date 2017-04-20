From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 13:39:42 +0200
Message-ID: <20170420113942.GD1886@nanopsycho.orion>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
 <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
 <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
 <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36199 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942311AbdDTLjp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 07:39:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id u65so2553491wmu.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 04:39:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 20, 2017 at 12:09:28PM CEST, Yuval.Mintz@cavium.com wrote:
>> > Dump some internal state about VFs through debugfs. This provides
>> > information not available with 'ip link show'.
>> 
>> such as?
>> 
>> donnwantobethedebugfspolice, but still, in the 2-3 times we tried to push
>> debugfs to MLNX NIC drivers, Dave disallowed that, and lately the switch
>> team even went further and deleted that portion of the mlxsw driver -- all to
>> all,  I don't see much point for these type of changes, thoughts?
>
>Don't want to hikjack your thread, but continuing this topic -
>Is there some flat-out disapproval for debugfs in net-next now?

It was mentioned by DaveM on the list multiple times.


>
>We're currently internally engaged with adding qed support for register dumps
>[~equivalents for `ethtool -d' outputs] through debugfs, on behalf of storage
>drivers [qedi/qedf] lacking the API for doing that.

That sounds wrong. Either introduce a generic infra to expose the info you
need or you don't do that. For your inhouse debugging, you should have
oot patch to expose whatever you need.
