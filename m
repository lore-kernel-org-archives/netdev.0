From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Wed, 2 Nov 2016 16:23:25 +0100
Message-ID: <20161102152325.GK1713@nanopsycho.orion>
References: <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion>
 <58177712.4000208@gmail.com>
 <20161031171229.GB2895@nanopsycho.orion>
 <58179CE4.2080400@gmail.com>
 <20161101084643.GA1707@nanopsycho.orion>
 <5818B11C.2040004@gmail.com>
 <20161102080723.GD1713@nanopsycho.orion>
 <581A03AE.8050006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>, Jakub Kicinski <kubakici@wp.pl>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com,
        Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38726 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754875AbcKBPX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:23:29 -0400
Received: by mail-wm0-f49.google.com with SMTP id n67so44393694wme.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:23:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <581A03AE.8050006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 02, 2016 at 04:18:06PM CET, john.fastabend@gmail.com wrote:
>On 16-11-02 01:07 AM, Jiri Pirko wrote:
>> Tue, Nov 01, 2016 at 04:13:32PM CET, john.fastabend@gmail.com wrote:

[...]


>[...]>
>>>
>>> Same question as above are we _really_ talking about pushing the entire
>>> programmability of the device via 'tc'. If so we need to have a vendor
>>> say they will support and implement this?
>> 
>> We need some API, and I believe that TC is perfectly suitable for that.
>> Why do you think it's a problem?
>> 
>
>For runtime configuration completely agree. For device configuration
>I don't see the advantage of adding an entire device specific compiler
>in the driver. The device is a set of CAMs, TCAMs, ALUs, instruction
>caches, etc. its not like a typical NIC/switch where you just bang
>some registers. Unless its all done in firmware but that creates an
>entirely different set of problems like how to update your compiler.
>
>Bottom line we need to have a proof point of a driver in kernel
>to see exactly how a P4 configuration would work. Again runtime config
>and device topology/capabilities discovery I'm completely on board.

I think we need to implement P4 world in rocker. Any volunteer? :)
