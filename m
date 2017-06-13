From: Mason <slash.tmp@free.fr>
Subject: Re: Toggling link state breaks network connectivity
Date: Tue, 13 Jun 2017 17:47:02 +0200
Message-ID: <51eb8306-64e5-f528-d663-be80c73098f1@free.fr>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
 <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
 <17e1e9c3-7adb-05fe-18cd-ce6db4ac792d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:10472 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751758AbdFMPrP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 11:47:15 -0400
In-Reply-To: <17e1e9c3-7adb-05fe-18cd-ce6db4ac792d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/06/2017 17:36, Florian Fainelli wrote:

> On 06/13/2017 08:07 AM, Mason wrote:
>
>> I did note something that seems important.
>> If I toggle the link state in software, then connectivity breaks.
>> If I unplug the ethernet cable, and replug, connectivity remains.
> 
> What does that actually mean? If you disconnect the cable a link state
> should be notified and another link state should be notified, even if
> that happens faster than the PHYLIB polling time (1s).

Sorry for being unclear.

If I unplug/replug the cable, ping still works afterward.
(Packet RX appears to be *not* wedged)

If I toggle the link state in SW (set link down/set link up),
I can no longer ping afterward.
(Packet RX appears to be wedged, so ARP replies are not seen)

Maybe the two experiments are too unrelated to consider
the different results relevant in any way?

Regards.
