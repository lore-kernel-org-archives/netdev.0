From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] pq3: Add default tbi address
Date: Sat, 3 Dec 2011 14:15:44 -0600
Message-ID: <CAKWjMd52BhV0j3R93Cw8usBxZwbMCY70x=BAmV7dH-WyWRUyFA@mail.gmail.com>
References: <1322809549-32622-1-git-send-email-afleming@freescale.com>
	<1322809549-32622-2-git-send-email-afleming@freescale.com>
	<B84C6222-2359-46D5-BA54-5024E43ECD3F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59269 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab1LCUPp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 15:15:45 -0500
Received: by ywa9 with SMTP id 9so3556665ywa.19
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2011 12:15:44 -0800 (PST)
In-Reply-To: <B84C6222-2359-46D5-BA54-5024E43ECD3F@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi | =A0 =A05 +++++
>> arch/powerpc/boot/dts/fsl/pq3-etsec2-0.dtsi | =A0 =A05 +++++
>> 2 files changed, 10 insertions(+), 0 deletions(-)
>
> This doesn't seem correct, meaning this should really be in the board=
 .dts not in the IP.
>
> I think the driver should check and warn if this property doesn't exi=
st.

Hmm... in principle, I agree with you. I suppose I was just being
lazy, and avoiding changing all the device trees again. However, it's
not an unreasonable default. A search through *all* of the device
trees for the tbi node indicates that 0x11 is chosen about 50% of the
time.

However, I'll devise a patch which complains if the node isn't found,
and another patch which modifies all of the offending device trees.

Andy
