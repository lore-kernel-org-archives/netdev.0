From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 11:20:21 -0400 (EDT)
Message-ID: <20170420.112021.167483274923043370.davem@davemloft.net>
References: <20170420015750.6828-5-jeffrey.t.kirsher@intel.com>
        <CAJ3xEMiCuV5A_Ccy7=mKSjc9xxhg4enUxDq-MM-cO3YjSa439A@mail.gmail.com>
        <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, jeffrey.t.kirsher@intel.com,
        mitch.a.williams@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970385AbdDTPU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:20:26 -0400
In-Reply-To: <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 20 Apr 2017 10:09:28 +0000

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
> Don't want to hikjack your thread, but continuing this topic -
> Is there some flat-out disapproval for debugfs in net-next now?
> 
> We're currently internally engaged with adding qed support for register dumps
> [~equivalents for `ethtool -d' outputs] through debugfs, on behalf of storage
> drivers [qedi/qedf] lacking the API for doing that.

I really hate to see debugfs things in networking drivers.  It's a
complete cop out for doing things properly.

I push back, but I can only fight too much.  If people want to keep
adding stupid poorly designed crap endlessly to their drivers there
is only so much I can do...
