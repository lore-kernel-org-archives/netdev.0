From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [uclinux-dist-devel] [PATCH RFC net-next 2/4] bfin_mac:
 replace sys time stamps with raw ones instead.
Date: Wed, 31 Oct 2012 09:36:53 +0100
Message-ID: <20121031083652.GC2327@netboy.at.omicron.at>
References: <cover.1348851539.git.richardcochran@gmail.com>
 <84396eacd75b4abed36a7819d8c2c33f9ced1ad5.1348851539.git.richardcochran@gmail.com>
 <CAA_GA1dWgav0fP3wJNFQW=VE9Qh-V8NBHqsmNoXaRny+5dnewg@mail.gmail.com>
 <20121030134112.GB2283@netboy.at.omicron.at>
 <CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40840 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935097Ab2JaIhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 04:37:06 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so593563eek.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 01:37:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA_GA1fW2zA2j66y7zfVe6+U-pb1=3mOyFFH+oDHimMFAXyH7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 02:29:23PM +0800, Bob Liu wrote:

> Any guide how to use ptp4l to sync system time between two machines
> over ethernet?

You can run ptp4l on two machines like this

  ptp4l -i eth0 -q -v     # master
  ptp4l -i eth0 -q -v -s  # slave

and you should see the "master offset" on the slave converge within
about 30 seconds or so.

Thanks,
Richard
