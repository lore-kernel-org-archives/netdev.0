From: Bob Beers <bob.beers@gmail.com>
Subject: Re: wanPMC-CxT1E1
Date: Fri, 6 Nov 2009 10:25:36 -0500
Message-ID: <4f6ba3b0911060725i574bbe63n10f169ed2641bf84@mail.gmail.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	 <20091026204144.GA28436@kroah.com>
	 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
	 <m3d4454phz.fsf@intrepid.localdomain>
	 <4f6ba3b0911021241gb6d9684ga76228013e0f5f14@mail.gmail.com>
	 <20091102205911.GA23443@kroah.com>
	 <4f6ba3b0911021316v16ff7431s4dfa939743541df6@mail.gmail.com>
	 <4f6ba3b0911021335k3054da38x56fe72ac7ea8781c@mail.gmail.com>
	 <4f6ba3b0911021339v20d7692fm52bcd5208002d6e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:51952 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759042AbZKFPZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 10:25:32 -0500
Received: by bwz27 with SMTP id 27so1272330bwz.21
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 07:25:36 -0800 (PST)
In-Reply-To: <4f6ba3b0911021339v20d7692fm52bcd5208002d6e4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

I don't mean to seem impatient, but is cxt1e1 in staging yet?

When it is, do I 'git pull' or re-baseline, or what? I don't mean
 to cause you too much extra work, but once I get the hang of
 this, I should be giving more than I'm taking.

I started over with a git clone of 2.6.31.y (vs 2.6.32.rcX) and
 could submit a new patch that does not have the two Makefile
 errors.  It compiles and I can modprobe the driver, but on
 modprobe -r, or attempting to use the pmcc4cfg util, my
 system locks up, maybe due to the incomplete port of the
 2 INIT_WORK() calls.

I want to first fix the unload problem, then remove all the
 kernel version checking stuff.  After that, I thought would be
 a good time to start fixing coding style issues, so that it will
 not be too painful for others to look at.

BTW, where should the pmcc4cfg source code go?  It needs a
 change in the Makefile before it compiles correctly.

thanks,
-- 
-Bob Beers
