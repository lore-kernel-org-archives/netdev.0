From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [RFC 3/4] nfp: make use of extended ack
 message reporting
Date: Wed, 26 Apr 2017 20:44:56 +0200
Message-ID: <20170426184455.GA1728@vergenet.net>
References: <9765d004-de19-7cf2-fcfc-1d2e72cded43@mojatatu.com>
 <20170425.102022.219410555949403896.davem@davemloft.net>
 <20170426111315.GC28251@vergenet.net>
 <20170426.104416.270999555163740292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl, oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36600 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965286AbdDZSpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:45:11 -0400
Received: by mail-wm0-f51.google.com with SMTP id u65so58903752wmu.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 11:45:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170426.104416.270999555163740292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 10:44:16AM -0400, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Wed, 26 Apr 2017 13:13:16 +0200
> 
> > On Tue, Apr 25, 2017 at 10:20:22AM -0400, David Miller wrote:
> >> From: Jamal Hadi Salim <jhs@mojatatu.com>
> >> Date: Tue, 25 Apr 2017 08:42:32 -0400
> >> 
> >> > So are we going to standardize these strings?
> >> 
> >> No.
> >> 
> >> > i.e what if some user has written a bash script that depends on this
> >> > string and it gets changed later.
> >> 
> >> They can't do that.
> >> 
> >> It's free form extra information an application may or not provide
> >> to the user when the kernel emits it.
> > 
> > I don't feel strongly about this and perhaps it can be revisited at some
> > point but perhaps it would be worth documenting that he strings do not
> > form part of the UAPI as my expectation would have been that they do f.e. to
> > facilitate internationalisation.
> 
> These two things are entirely separate.
> 
> We can maintain uptodate translations of the strings, yet document that
> they can change at any time and are thus not UAPI.

Thanks, I see that now.
