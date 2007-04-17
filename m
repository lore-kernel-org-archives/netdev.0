From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: TCP connection stops after high load.
Date: Tue, 17 Apr 2007 10:58:04 +0300
Message-ID: <7e63f56c0704170058m35d44a8ajfe5d97c4c7a8d87a@mail.gmail.com>
References: <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>
	 <4623BB7B.3010705@psc.edu>
	 <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
	 <20070416.121558.48807497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org, greearb@candelatech.com,
	"Michael Moser" <moser.michael@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:48569 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbXDQH6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 03:58:05 -0400
Received: by ug-out-1314.google.com with SMTP id 44so105480uga
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 00:58:04 -0700 (PDT)
In-Reply-To: <20070416.121558.48807497.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On 4/16/07, David Miller <davem@davemloft.net> wrote:
> > > Commit: 53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
> > > Author: John Heffner <jheffner@psc.edu> Fri, 16 Mar 2007 15:04:03 -0700
> > >
> > >      [TCP]: Fix tcp_mem[] initialization.
> > >      Change tcp_mem initialization function.  The fraction of total memory
> > >      is now a continuous function of memory size, and independent of page
> > >      size.
> >
> >
> > Kernels 2.6.19 and 2.6.20 series are effectively broken right now.
> > Don't you wish to patch them?
>
> Can you verify that this patch actually fixes your problem?

Yes, it fixes.

After the patch curl-loader works with patched 2.6.19.7 and
with patched 2.6.20.7 using simulteneous 3000 local connections smothly,
and even better than with referred as a "good" 2.6.18.3.


Besides that the tcp_mem status for my machine:

kernel                             tcp_mem
------------------------------------------------------
2.6.19.7                     3072    4096     6144
2.6.19.7-patched    45696   60928   91392
2.6.20.7                     3072    4096     6144
2.6.20.7-patched    45696   60928   91392

The patch was applied smothly just with line offsets.

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://curl-loader.sourceforge.net
An open-source HTTP/S, FTP/S traffic
generating, and web testing tool.
