From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Toggling link state breaks network connectivity
Date: Tue, 13 Jun 2017 08:36:13 -0700
Message-ID: <17e1e9c3-7adb-05fe-18cd-ce6db4ac792d@gmail.com>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
 <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
 <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33551 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdFMPgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 11:36:16 -0400
Received: by mail-qt0-f182.google.com with SMTP id u12so176894948qth.0
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 08:36:16 -0700 (PDT)
In-Reply-To: <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/13/2017 08:07 AM, Mason wrote:> I did note something that seems
important.
> 
> If I toggle the link state in software, then connectivity breaks.
> 
> If I unplug the ethernet cable, and replug, connectivity remains.

What does that actually mean? If you disconnect the cable a link state
should be notified and another link state should be notified, even if
that happens faster than the PHYLIB polling time (1s).

> 
> The difference is that plugging/unplugging doesn't call the
> .ndo_stop callback. But 'ip link set eth0 down' does call it.
> 
> Should the .ndo_stop callback be symmetric to the .ndo_open callback?

Yes obviously.

> In other words, should .ndo_open(); .ndo_stop(); be a NOP?

-- 
Florian
