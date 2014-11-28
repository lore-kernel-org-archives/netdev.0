From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Multiple DSA switch on shared MII
Date: Fri, 28 Nov 2014 04:21:29 -0800
Message-ID: <547868C9.90903@gmail.com>
References: <CAOi_9k8NwpVFxg=9VOagVt3m6hn2uLKuCZ_0-+4PciJNRWuTmA@mail.gmail.com>	<CAGVrzcaG_uYpmmgC252ObHJ9Cmt91-BUtB3uOfPJHV6RhkRU1Q@mail.gmail.com>	<CAOi_9k8WySmjm5cdFn1kJQuE7cJ1rDyM9SV2RvbcmbB+UeTVdQ@mail.gmail.com>	<547636B7.3060706@gmail.com>	<CAOi_9k_3+9U4q=SHdeEJOi_efHkRvYdTQ=UBqZtafgDAv_oOHg@mail.gmail.com> <CAOi_9k9h4N-uPf7shapytV+rCtHFWiVco26hCVjTMN=00o8KAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Rajib Karmakar <rajibkit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:52298 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaK1EVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 23:21:31 -0500
Received: by mail-oi0-f48.google.com with SMTP id u20so4190488oif.21
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 20:21:31 -0800 (PST)
In-Reply-To: <CAOi_9k9h4N-uPf7shapytV+rCtHFWiVco26hCVjTMN=00o8KAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/11/2014 23:18, Rajib Karmakar a =C3=A9crit :
> This could be a naive question; but can I add all LAN and WAN
> interfaces in a single DSA switch (one cpu port, one netdev)?

One DSA switch is backed by a single netdev, I would rather register tw=
o
dsa switches, even if they actually map to the same physical switch,
rather than hacking around a single instance to work with multiple
network devices.

Thanks
--
=46lorian
