From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 08:48:56 +0200
Message-ID: <1338360536.2760.85.camel@edumazet-glaptop>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
	 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62530 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab2E3GtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 02:49:00 -0400
Received: by bkcji2 with SMTP id ji2so3782213bkc.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 23:48:59 -0700 (PDT)
In-Reply-To: <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 08:28 +0200, Jean-Michel Hautbois wrote:

> If this can help, setting tx queue length to 5000 seems to make the
> problem disappear.

Then you should have drops at Qdisc layer (before your change to 5000)

tc -s -d qdisc

> I didn't specified it : MTU is 4096, UDP packets are 4000 bytes.
