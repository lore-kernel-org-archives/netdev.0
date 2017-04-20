From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 22:25:03 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D80551D1A@FMSMSX113.amr.corp.intel.com>
References: <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
        <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
        <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420.112021.167483274923043370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: 'David Miller' <davem@davemloft.net>,
        "Yuval.Mintz@cavium.com" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36284 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944361AbdDTWZF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 18:25:05 -0400
In-Reply-To: <20170420.112021.167483274923043370.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of David Miller
> Sent: Thursday, April 20, 2017 8:20 AM
> To: Yuval.Mintz@cavium.com
> Cc: gerlitz.or@gmail.com; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>;
> Williams, Mitch A <mitch.a.williams@intel.com>; netdev@vger.kernel.org;
> nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
> 
> From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
> Date: Thu, 20 Apr 2017 10:09:28 +0000
> 
> >> > Dump some internal state about VFs through debugfs. This provides
> >> > information not available with 'ip link show'.
> >>
> >> such as?
> >>
> >> donnwantobethedebugfspolice, but still, in the 2-3 times we tried to push
> >> debugfs to MLNX NIC drivers, Dave disallowed that, and lately the switch
> >> team even went further and deleted that portion of the mlxsw driver --
> all to
> >> all,  I don't see much point for these type of changes, thoughts?
> >
> > Don't want to hikjack your thread, but continuing this topic -
> > Is there some flat-out disapproval for debugfs in net-next now?
> >
> > We're currently internally engaged with adding qed support for register
> dumps
> > [~equivalents for `ethtool -d' outputs] through debugfs, on behalf of
> storage
> > drivers [qedi/qedf] lacking the API for doing that.
> 
> I really hate to see debugfs things in networking drivers.  It's a
> complete cop out for doing things properly.
> 
> I push back, but I can only fight too much.  If people want to keep
> adding stupid poorly designed crap endlessly to their drivers there
> is only so much I can do...

Honestly, Dave, I try very hard not to put random crap into debugfs. I felt that there was enough utility here to send this one up.

We already have debugfs hooks upstream that allow us to dump information about a specific VSI. This just adds a tiny bit to that to allow us to link a VF with its specific VSI. It's the missing link, if you will.

I'm not adding backdoor hooks to do naughty things, I'm just (very slightly) enhancing what's already there.

This particular piece has been very useful for my debugging, and we have customers that have asked for it as well.

If you still want to reject this, I won't fight and cry and stomp my little feet. But I honestly think that this a) has genuine utility, b) is fairly device specific, and c) isn't crap.

-Mitch
