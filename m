From: Thiago Macieira <thiago.macieira@intel.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Wed, 16 Aug 2017 16:55:47 -0700
Message-ID: <2308911.oTjYErtyEh@tjmaciei-mobl1>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502914822.2796.6.camel@redhat.com> <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:65244 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752358AbdHPX4S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 19:56:18 -0400
In-Reply-To: <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, 16 August 2017 16:27:17 PDT Willem de Bruijn wrote:
> Actually, it is safe even without the check. Overflow of the signed integer
> is benign here.

Usually, it's a bad idea to allow UB to happen.

Where is the overflow? I didn't see it in the patches so far.

-- 
Thiago Macieira - thiago.macieira (AT) intel.com
  Software Architect - Intel Open Source Technology Center
