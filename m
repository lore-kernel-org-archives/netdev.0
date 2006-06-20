From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 20 Jun 2006 01:28:25 -0700
Message-ID: <c0a09e5c0606200128m2c468ce8w51feada2700c1930@mail.gmail.com>
References: <20060607164801.GX24227@waste.org>
	 <1149787174.2928.3.camel@strongmad> <x49ac8nwo83.fsf@redhat.com>
	 <20060612001356.GA5112@localhost.localdomain>
	 <1150130534.2879.9.camel@strongmad>
	 <20060612180600.GB3790@hmsreliant.homelinux.net>
	 <20060614204158.GA3967@hmsreliant.homelinux.net>
	 <Pine.CYG.4.58.0606141635440.2888@mawilli1-desk2.amr.corp.intel.com>
	 <20060615124355.GA32582@tuxdriver.com>
	 <Pine.CYG.4.58.0606151344120.928@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.206]:29862 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S965015AbWFTI20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 04:28:26 -0400
Received: by wx-out-0102.google.com with SMTP id h28so908637wxd
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 01:28:25 -0700 (PDT)
To: linville@tuxdriver.com
In-Reply-To: <Pine.CYG.4.58.0606151344120.928@mawilli1-desk2.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(trimmed CC to just netdev)

> > > One of our engineers (on the I/O AT team) has been tasked with modifying
> > > the Linux kernel to properly support multiple hardware queues (both TX and
> > > RX).  We'll make sure that he looks at the netpoll interface as part of
> > > that process.
> >
> > Might I ask who this is?  I might like to ping him/her on this topic.
> > There is potentially some overlap with wireless, at least on the
> > transmit side.
> > John W. Linville

Hi John, so yeah we want multiple TX queues on wired ethernet for QoS,
same as wireless. Also for SMP scaling (maybe not needed until 10G+).
Did wireless people settle on a design since the email thread in
January?

Regards -- Andy
