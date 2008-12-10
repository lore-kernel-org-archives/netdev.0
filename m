From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: qmgr for ixp4xx
Date: Wed, 10 Dec 2008 17:32:55 +0100
Message-ID: <b0438a630812100832l417f4df6lbbf5263e338baff2@mail.gmail.com>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	 <m3zljby7jm.fsf@maximus.localdomain>
	 <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	 <m31vwmlidh.fsf@maximus.localdomain>
	 <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
	 <m3fxl2jx0v.fsf@maximus.localdomain>
	 <b0438a630812090148u4c42a193q833c913a1a27e0a9@mail.gmail.com>
	 <m3fxkwvoee.fsf@maximus.localdomain>
	 <b0438a630812100104i135f6bfawb9cff915202c39ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:17400 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbYLJQc4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 11:32:56 -0500
Received: by yx-out-2324.google.com with SMTP id 8so271624yxm.1
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 08:32:55 -0800 (PST)
In-Reply-To: <b0438a630812100104i135f6bfawb9cff915202c39ce@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Complementing the previous mail.

I have implemented 64 queues for ixp4xx (following Karl's patch).

My idea was to use queues 32-39 for my eight txreadyq.

As rxq and txreadyq from ethernet in NPEB and NPEC conflict with the
queues in the ixp4xx_hss driver, I have decided to use queues 40-43
for them. Solving a problem with qmgr_stat_overflow, I have been able
to configure the interface (ethernet in NPEB). However not even a ping
can be sent.

Thinking that the problem was using >=3D 32 queues, I decided to use
queues 23-26... With the same result. So queues 3, 4, 20 and 21 seem
to be fixed for ethernet. But they are also used for HSS!!!

Any ideas?

Miguel =C1ngel
