From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: d80211 sysfs
Date: Tue, 11 Jul 2006 10:46:34 +0200
Message-ID: <a32f33a40607110146k580eff00r8ca909c52b0548c4@mail.gmail.com>
References: <a32f33a40607080505wd3c9200sdf50ff814fd5afb@mail.gmail.com>
	 <20060710172702.288680e9@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:17871 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750753AbWGKIqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 04:46:34 -0400
Received: by py-out-1112.google.com with SMTP id x31so1425948pye
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 01:46:34 -0700 (PDT)
To: "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <20060710172702.288680e9@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Ok I think I am closer to the source of the problem.
Some users just verified that the problem does not excist in the 2.6.17 kernel.
So it must have been an issue already resolved in the kernel.

I'll ask my testers to upgrade their kernels, or perhaps I am going to
ask them to use the wireless-dev or dscape git tree to test rt2x00.

Thanks.

Ivo
