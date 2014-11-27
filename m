From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Thu, 27 Nov 2014 13:30:40 +0100
Message-ID: <20141127123040.GA4443@localhost.localdomain>
References: <1416938286-14147-2-git-send-email-willemb@google.com>
 <20141125.134240.861582393401487675.davem@davemloft.net>
 <CA+FuTSdT9=Hi7K3OnMxVRiK8PmS4=DvVqLumWx74OEz3okx23A@mail.gmail.com>
 <20141125.145434.1790615963499624322.davem@davemloft.net>
 <CALCETrXHdSVC-YLsdjHxAp3rU2gGFZaz8NNgaTKYgjM-ah3z+A@mail.gmail.com>
 <CA+FuTScmwYyrU-LOK5dvbdcp4n=wig7GTdV1gmViS-2gJ4Q9ZA@mail.gmail.com>
 <CALCETrW+2Q-R8ekVW=u=3Xb5YvYK=4RnuuWCvAG8pyc9eG6DQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:61948 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803AbaK0Map (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 07:30:45 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so15594521wiw.13
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 04:30:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrW+2Q-R8ekVW=u=3Xb5YvYK=4RnuuWCvAG8pyc9eG6DQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 04:36:39PM -0800, Andy Lutomirski wrote:
> Is there any reason to believe that unconditionally dropping the
> headers would break anything?  I find it a bit hard to believe that
> anyone has actually implemented logic to figure out *what* L2 header
> type should be decoded and decode it.

Documentation/networking/timestamping/timestamping.c

				else if (!memcmp(sync, data + res - sizeof(sync),
							sizeof(sync)))
					printf(" => GOT OUR DATA BACK (HURRAY!)");

The example program looks from the end of the buffer, ignoring the lower headers.

Thanks,
Richard
