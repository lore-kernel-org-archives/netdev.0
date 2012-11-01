From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac:
 replace sys time stamps with raw ones instead.
Date: Thu, 1 Nov 2012 10:35:40 +0100
Message-ID: <20121101093540.GB5949@netboy.at.omicron.at>
References: <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
 <CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
 <20121030134112.GB2283@netboy.at.omicron.at>
 <CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
 <20121031083652.GC2327@netboy.at.omicron.at>
 <CAA_GA1cQojiaJat8gGmp3XYZVGOtKi2xoFS08hsYTGssdbWcRg@mail.gmail.com>
 <20121031124638.GA14197@netboy.at.omicron.at>
 <CAA_GA1eLXajk+wfwf7QYVoabDDeXLZecaTFX+6JRyoaYOyztQQ@mail.gmail.com>
 <20121101084111.GC2637@netboy.at.omicron.at>
 <CAA_GA1f=2ubb1z6rr1L8TR54cwh1NQcKiiaZqqv2r3mjX1wL7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Miroslav Lichvar <mlichvar@redhat.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	device-drivers-devel@blackfin.uclinux.org,
	Jacob Keller <jacob.e.keller@intel.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Patrick Ohly <patrick.ohly@intel.com>,
	David Miller <davem@davemloft.net>
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:53069 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab2KAJfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 05:35:51 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so899686eaa.19
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 02:35:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA_GA1f=2ubb1z6rr1L8TR54cwh1NQcKiiaZqqv2r3mjX1wL7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 01, 2012 at 04:54:30PM +0800, Bob Liu wrote:
> 
> date in master side is:
> root:/> date
> Thu Dec 21 01:34:26 UTC 2006
> root:/>

What is the time on the master from the 'testptp -g' command?
 
> So the system time didn't sync.

I guess that you need to set the PHC time on the master, using 'testptp -s'.

[ There are always two clocks on each host, the Linux system time and
  the PHC time in the hardware clock. ]

Thanks,
Richard
