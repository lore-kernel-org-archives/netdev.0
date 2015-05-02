From: Andy Lutomirski <luto@amacapital.net>
Subject: sfc: Please add rss_cpus=hyperthreads support
Date: Fri, 1 May 2015 17:03:04 -0700
Message-ID: <CALCETrWpJMT-SfKKhjRfeNRrXS6C6+SUuzOCuSYwMZbMCqB+tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Shradha Shah <sshah@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35269 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbbEBAD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:03:26 -0400
Received: by labbd9 with SMTP id bd9so72866432lab.2
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:03:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi sfc people-

Can you please port the rss_cpus=hyperthreads feature from the
OpenOnload driver to the upstream driver?  The fact that sticking:

options sfc rss_cpus=hyperthreads

into modprobe.conf causes sfc to fail to load when OpenOnload isn't
installed is incredibly annoying, and the option is genuinely useful.

Thanks,
Andy
