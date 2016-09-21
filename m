From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 02/15] i40e: Enable VF specific ethtool statistics via
 VF Port representor netdevs
Date: Wed, 21 Sep 2016 09:54:43 +0300
Message-ID: <CAJ3xEMiKDZ5uAi_JS7U=A7e81khMtXPWWiGGiozAC-=R=b6fOA@mail.gmail.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1474429432-102772-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJ3xEMhM63HxyQxv3YyN7Lb3uCOWsA3aqfkhnuzdJqtNRty8Zw@mail.gmail.com> <57E221B3.2000004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:32936 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753367AbcIUGyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 02:54:49 -0400
Received: by mail-oi0-f44.google.com with SMTP id r126so49567281oib.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 23:54:44 -0700 (PDT)
In-Reply-To: <57E221B3.2000004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 8:59 AM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 9/20/2016 9:26 PM, Or Gerlitz wrote:

>> Now, when the SW stats are finally upstream for 4.9 in net-next, the
>> correct approach
>> for the VF reps counters is to follow the architecture presented there
>> [1] -- and this is
>> for the netlink based standard counters. Once you do that, there's no
>> need to expose
>> the VF HW counters through  ethtool of the VF rep.

> Sure. Will look into it.  However, i think we can keep ethtool support also
> as VFPR represents the switch port corresponding to the VF.

Exactly b/c the VFPR represented the VF switch port, their "normal" stats
is what you are exposing here through ethtool, you can just drop this and
move to the strategy introduced in Nogah's work. Once you support TX/RX
on the VFPRs you can also add the SW stats she added too.
