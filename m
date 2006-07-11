From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Fwd: d80211 sysfs
Date: Tue, 11 Jul 2006 10:08:49 +0200
Message-ID: <a32f33a40607110108obf692f6l559212286b5df366@mail.gmail.com>
References: <a32f33a40607080505wd3c9200sdf50ff814fd5afb@mail.gmail.com>
	 <20060710172702.288680e9@griffin.suse.cz>
	 <a32f33a40607110107n7fcc0cf0v3f72c44710e87f44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:36737 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750734AbWGKIIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 04:08:50 -0400
Received: by py-out-1112.google.com with SMTP id x31so1404218pye
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 01:08:49 -0700 (PDT)
To: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <a32f33a40607110107n7fcc0cf0v3f72c44710e87f44@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the double mail.
Forgot to CC netdev list.

Hi,

> > Since I didn't want to loose any tested because of the new field in
> > the net_device structure,
> > I have used the base_addr field instead and used the following access functions:
>
> This will horribly fail when you send something to master device
> (wmaster0) directly. For example, having ipv6 enabled is enough to
> produce some funny Oopses.
>
> > kernel BUG at fs/sysfs/symlink.c:88!
> > invalid opcode: 0000 [#1]
> > SMP
>
> d80211 stack is not SMP safe yet. Is this reproducible on non-SMP
> non-preemptible kernel without your base_addr patches?

Yes, I have verified this problem on my PC as well and it is running a
non-SMP kernel.
I have also checked the reports from other users and it seems to
affect both SMP as non-SMP users/kernels.

Ivo
