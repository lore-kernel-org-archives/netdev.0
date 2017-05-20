From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 0/4] Configuring traffic classes via new hardware offload
 mechanism in tc/mqprio
Date: Sun, 21 May 2017 00:15:02 +0300
Message-ID: <CAJ3xEMjTDW7sQ5CFmTyR5xMpin_WFFQg-S8imWMBpXWuS1zvVw@mail.gmail.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        kiran.patil@intel.com,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Neerav Parikh <neerav.parikh@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33379 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753856AbdETVPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 17:15:04 -0400
Received: by mail-oi0-f50.google.com with SMTP id w10so126268072oif.0
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 14:15:03 -0700 (PDT)
In-Reply-To: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 3:58 AM, Amritha Nambiar
<amritha.nambiar@intel.com> wrote:
> The following series introduces a new harware offload mode in tc/mqprio

Wait, we have already a HW QoS model introduced by John F and Co
couple of years ago,  right?

Please elaborate in few sentence if you are extending it/replacing it,
why we want to do that and what are the implications on existing
applications UAPI wise.

Below you just say in the new mode Qos is configured with knobs XYZ --
this is way not enough

> where the TCs, the queue configurations and bandwidth rate limits
> are offloaded to the hardware.


> The i40e driver enables the new mqprio hardware offload mechanism factori=
ng the TCs, queue configuration and bandwidth rates by creating HW channel =
VSIs.
>
> In this mode, the priority to traffic class mapping and the user specifie=
d queue ranges are used to configure the traffic class when the 'hw' option=
 is set to 2. This is achieved by creating HW channels(VSI). A new channel =
is created for each of the traffic class configuration offloaded via mqprio=
 framework except for the first TC (TC0) which is for the main VSI. TC0 for=
 the main VSI is also reconfigured as per user provided queue parameters. F=
inally, bandwidth rate limits are set on these traffic classes through the =
mqprio offload framework by sending these rates in addition to the number o=
f TCs and the queue configurations.
