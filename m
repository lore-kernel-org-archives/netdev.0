From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net v2 1/2] bridge: implement missing ndo_uninit()
Date: Sat, 8 Apr 2017 16:23:09 +0200
Message-ID: <CA+Nub0Z2ODKCbs8XGDDxd2Y1aiZ4WCz_tfhLrMyU+svv1iY0_Q@mail.gmail.com>
References: <20170408114159.12722-1-idosch@mellanox.com> <20170408114159.12722-2-idosch@mellanox.com>
 <20170408093042.20b08c5d@plumbers-lap.home.lan> <20170408134938.GA28955@splinter>
 <59220a2b-aa54-844d-cda5-63a42b88f188@cumulusnetworks.com> <20170408101401.10ee916e@plumbers-lap.home.lan>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36062 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751841AbdDHOXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 10:23:11 -0400
Received: by mail-io0-f193.google.com with SMTP id 68so9933522ioh.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 07:23:11 -0700 (PDT)
In-Reply-To: <20170408101401.10ee916e@plumbers-lap.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-08 16:14 GMT+02:00 Stephen Hemminger <stephen@networkplumber.org>:
> On Sat, 8 Apr 2017 17:05:48 +0300
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>
>> On 08/04/17 16:49, Ido Schimmel wrote:
>> > On Sat, Apr 08, 2017 at 09:30:42AM -0400, Stephen Hemminger wrote:
>> >> On Sat, 8 Apr 2017 14:41:58 +0300
>> >> <idosch@mellanox.com> wrote:
>> >>
>> >>>  static void br_dev_free(struct net_device *dev)
>> >>>  {
>> >>> - struct net_bridge *br = netdev_priv(dev);
>> >>> -
>> >>> - free_percpu(br->stats);
>> >>>   free_netdev(dev);
>> >>>  }
>> >>>
>> >>
>> >> Since the only thing left is free_netdev, you can now just set dev->destructor
>> >> to be free_netdev.
>> >
>> > Fine.
>> >
>> > Beside stylistic issues, I would appreciate comments on how this should
>> > be handled. Are we reverting the patch in the Fixes line or applying
>> > this patchset?
>> >
>> > I prefer the first option. Then after net is merged into net-next I can
>> > re-post this patchset with the requested changes.
>> >
>>
>> +1
>>
>>
>
> If this fixes the issue, then the one fix should go to stable, net and net-next.
> There is no good reason to have two versions.
>
+1
