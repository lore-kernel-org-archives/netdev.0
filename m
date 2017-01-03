From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH 5/6] i40e: Add TX and RX support in switchdev mode.
Date: Wed, 4 Jan 2017 01:03:54 +0200
Message-ID: <CAJ3xEMjGuKKge+_hqZPOg2fp3f50TdxGtbKFXwnCZ70rPxmuyw@mail.gmail.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
 <1483078863-22026-6-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMgDAUSE2gVD3dU4UuXFb7k_W-9QgHpg-0c7b5kxRC2=FQ@mail.gmail.com> <586693A6.5090105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36218 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753331AbdACXEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 18:04:30 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so72307540oie.3
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 15:03:55 -0800 (PST)
In-Reply-To: <586693A6.5090105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2016 at 7:04 PM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 12/30/2016 7:31 AM, Or Gerlitz wrote:

>> Are you exposing switchdev ops for the representators? didn't see that
>> or maybe it's in the 4th patch which didn't make it to the list?

> Not at this time. In the future patches when we offload fdb/vlan
> functionality, we could use switchdev ops.

but wait, this is the switchdev mode... even before doing any
offloading, you want (need) your representor netdevices to have the
same HW ID marking they are all ports of the same ASIC, this you can
do with the switchdev parent ID attribute.
