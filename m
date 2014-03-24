From: Alon Nafta <alon@privatecore.com>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3 buffer
 overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 10:35:37 -0700
Message-ID: <CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
References: <CAKPWWNHc8q-evx7TaTWX5SObd3iVm6YpFmepajRHgXmVgC713g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E77C0@AcuExch.aculab.com>
	<CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	<20140324.131733.723749970605014851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight@aculab.com>,
	netdev <netdev@vger.kernel.org>,
	Grant Grundler <grantgrundler@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36875 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbaCXRfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 13:35:39 -0400
Received: by mail-la0-f49.google.com with SMTP id mc6so3836169lab.22
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 10:35:38 -0700 (PDT)
In-Reply-To: <20140324.131733.723749970605014851.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I'm separating between HW misbehavior, and driver bugs than can lead
to code execution. Similar checks for this exact field are well
protected in other drivers, including the most common ones.

Moreover, a system can be protected from malicious HW, and in fact
doesn't have to trust HW at all (except for the CPU obviously).

On Mon, Mar 24, 2014 at 10:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Alon Nafta <alon@privatecore.com>
> Date: Mon, 24 Mar 2014 09:41:21 -0700
>
>> In regards to your comment about hardware-induced problems, from a
>> holistic point of view, IMHO any buffer overflow should get fixed.
>
> I completely disagree with you.
>
> If we had to accomodate every possible arbitrary mis-behavior of
> hardware, the drivers would be so bloated as to be nearly unusable.
