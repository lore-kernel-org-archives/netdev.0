From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Mon, 28 Feb 2011 03:11:46 +0200
Message-ID: <AANLkTinL3UhjOtmr3uyEkSiDT5NFJo=FbG5mKm3XaU8R@mail.gmail.com>
References: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com> <20110227160852.4f748c1f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54948 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab1B1BMI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 20:12:08 -0500
Received: by iyb26 with SMTP id 26so2467666iyb.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 17:12:07 -0800 (PST)
In-Reply-To: <20110227160852.4f748c1f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 2:08 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>> The check is triggered at network namespace deletion, so a moment
>> before deleting the netns should be fine.
>
> Although the kernel was compiled with netns, I never use net namespac=
es.


This can be triggered at shutdown when the init_net network namespace
is dismantled.

Are you getting this at shutdown time? If not, is it easily reproducibl=
e?
Can you post a .config?

--=20
=C2=A0.
=2E.: Lucian
