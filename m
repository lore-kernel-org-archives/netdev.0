From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev
 mode.
Date: Wed, 04 Jan 2017 14:46:38 -0800
Message-ID: <586D7B4E.2010308@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com> <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com> <586693A6.5090105@intel.com> <CAJ3xEMjGuKKge+_hqZPOg2fp3f50TdxGtbKFXwnCZ70rPxmuyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64770 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750853AbdADWq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 17:46:57 -0500
In-Reply-To: <CAJ3xEMjGuKKge+_hqZPOg2fp3f50TdxGtbKFXwnCZ70rPxmuyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 1/3/2017 3:03 PM, Or Gerlitz wrote:
> On Fri, Dec 30, 2016 at 7:04 PM, Samudrala, Sridhar
> <sridhar.samudrala@intel.com> wrote:
>> On 12/30/2016 7:31 AM, Or Gerlitz wrote:
>>> Are you exposing switchdev ops for the representators? didn't see that
>>> or maybe it's in the 4th patch which didn't make it to the list?
>> Not at this time. In the future patches when we offload fdb/vlan
>> functionality, we could use switchdev ops.
> but wait, this is the switchdev mode... even before doing any
> offloading, you want (need) your representor netdevices to have the
> same HW ID marking they are all ports of the same ASIC, this you can
> do with the switchdev parent ID attribute.
OK. I will add switchdev_port_attr_get() with PORT_PARENT_ID support in v3.

Thanks
Sridhar
