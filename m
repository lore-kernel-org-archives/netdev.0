From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac:
 replace sys time stamps with raw ones instead.
Date: Thu, 1 Nov 2012 09:41:11 +0100
Message-ID: <20121101084111.GC2637@netboy.at.omicron.at>
References: <cover.1348851539.git.richardcochran@gmail.com>
 <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
 <CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
 <20121030134112.GB2283@netboy.at.omicron.at>
 <CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
 <20121031083652.GC2327@netboy.at.omicron.at>
 <CAA_GA1cQojiaJat8gGmp3XYZVGOtKi2xoFS08hsYTGssdbWcRg@mail.gmail.com>
 <20121031124638.GA14197@netboy.at.omicron.at>
 <CAA_GA1eLXajk+wfwf7QYVoabDDeXLZecaTFX+6JRyoaYOyztQQ@mail.gmail.com>
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
Received: from mail-ea0-f174.google.com ([209.85.215.174]:62512 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab2KAIlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 04:41:24 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so882873eaa.19
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 01:41:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA_GA1eLXajk+wfwf7QYVoabDDeXLZecaTFX+6JRyoaYOyztQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 01, 2012 at 10:08:01AM +0800, Bob Liu wrote:
> How to use it?
 
ptp4l -i eth0 -q -v     # master
ptp4l -i eth0 -q -v -s  # slave

#
# Wait for state s2 on the slave_________
#                                        \
ptp4l[336.203]: master offset        569 s2 adj +102784 path delay 33666
#
# Then start phc2sys.
#

phc2sys -s /dev/ptp0

> But this can't work.

Can you post the output of the ptp4l and phc2sys on the slave?

Thanks again for testing this for me,
Richard
