From: =?UTF-8?B?QW5kcsOp?= Roth <neolynx@gmail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sun, 18 Sep 2016 22:42:40 +0200
Message-ID: <20160918224240.0bf5a9ed@gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
        <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        <netdev@vger.kernel.org>, <linux-amlogic@lists.infradead.org>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38541 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935992AbcIRUmp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 16:42:45 -0400
Received: by mail-wm0-f45.google.com with SMTP id 1so126233936wmz.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 13:42:43 -0700 (PDT)
In-Reply-To: <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

> For example, you could try disabling the scatter-gather or tx-cum
> via ethtool and seeing if there is some benefit; so we could image
> some problem on your HW or SYNP MAC integration for checksumming
> on tx side.

disabling the following: 
  ethtool -K eth0 sg off    
or:
  ethtool -K eth0 tx off    
does not prevent the network communication going down..

> Also you could check the AXI tuning and PBL value. To be honest
> (thinking about your problem) I can actually suspect some related
> problem on bus setup. So I suggest you to play with these value
> (better if you ask for having values from HW validation on your side).
> Otherwise the stmmac uses a default that cannot be good for your
> platform. For example, sometime I have seen that PBL is better if
> reduced to 8 instead of 32 and w/o 4xPBL...

how can I set those values ?

thanks for your time,

 andre
