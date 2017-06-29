From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next v2 6/6] ixgbe: Add malicious driver detection support
Date: Thu, 29 Jun 2017 21:19:58 +0000
Message-ID: <87618083B2453E4A8714035B62D67992B3E8A975@FMSMSX105.amr.corp.intel.com>
References: <CAJ3xEMgT62xt=TdFyY9vfRG+eOqvcLT+5m1WSGPtexygyrcB+w@mail.gmail.com>
        <87618083B2453E4A8714035B62D67992B3E89F1D@FMSMSX105.amr.corp.intel.com>
        <CAJ3xEMgAOMM3g0sqc6AfWLWf_VKwuHQGh_ZSYfmeQg=JotGbbg@mail.gmail.com>
 <20170629.142818.560549326785464904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Greenwalt, Paul" <paul.greenwalt@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: David Miller <davem@davemloft.net>,
        "gerlitz.or@gmail.com" <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23952 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753422AbdF2VUF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 17:20:05 -0400
In-Reply-To: <20170629.142818.560549326785464904.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, June 29, 2017 11:28 AM
>To: gerlitz.or@gmail.com
>Cc: Tantilov, Emil S <emil.s.tantilov@intel.com>; Kirsher, Jeffrey T
><jeffrey.t.kirsher@intel.com>; Greenwalt, Paul <paul.greenwalt@intel.com>;
>netdev@vger.kernel.org; nhorman@redhat.com; sassmann@redhat.com;
>jogreene@redhat.com
>Subject: Re: [net-next v2 6/6] ixgbe: Add malicious driver detection
>support
>
>From: Or Gerlitz <gerlitz.or@gmail.com>
>Date: Wed, 28 Jun 2017 17:28:59 +0300
>
>> On Wed, Jun 28, 2017 at 1:14 AM, Tantilov, Emil S
>> <emil.s.tantilov@intel.com> wrote:
>>
>>> Mainly because I am not sure that other (non-Intel) drivers will benefit
>from
>>> such an option. In normal operation this functionality should not cause
>issues
>>> and if it doesn't we may be able to deprecate the private flag in the
>future.
>>
>> If you think this functionality makes sense any driver running over HW
>> implementing
>> it would like to be able to expose that and hence you better not use
>> private flag.

As I mentioned I don't know if this will be useful for other drivers.
The i40e driver enables it by default without possibility to disable it
and if this protection does not cause problems for ixgbe then we may not
need the option in the future. Because of this I wasn't sure if it's
worth polluting the tools with options that may end up not being 
needed/used at all.
 
>> Are we sure the trust UAPI can't be extended for that matter?
>
>Yeah, we should probably make this a generic control if possible.

MDD is set globally for the device, while the trusted option is set per VF.
So if we do end up adding an option it probably won't work as extension for
trusted.

Thanks,
Emil
