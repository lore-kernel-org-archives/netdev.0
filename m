From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH] i40e: limit client interface to X722 hardware
Date: Tue, 4 Apr 2017 21:51:51 +0200
Message-ID: <b28317c2-fa35-2ee1-7bf2-c3ca7d24677b@kpanic.de>
References: <20170404143446.16359-1-sassmann@kpanic.de>
 <CAJ3xEMjvmXTAyLP2-BwHRj59uQeCNXA7XSX7kTA=8TmwwmzRkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:58914 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdDDTwJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 15:52:09 -0400
In-Reply-To: <CAJ3xEMjvmXTAyLP2-BwHRj59uQeCNXA7XSX7kTA=8TmwwmzRkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.04.2017 18:56, Or Gerlitz wrote:
> On Tue, Apr 4, 2017 at 5:34 PM, Stefan Assmann <sassmann@kpanic.de> wrote:
>> The client interface is meant for X722 iWARP support. Modprobing i40iw
>> on systems with X710/XL710 NICs currently may crash the system.
> 
> just curious may or crash? and why?

The backtrace I got was not really conclusive. The code is not meant to
be run on that hardware so I didn't bother to dig deeper.

  Stefan
