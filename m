From: Cong Wang <cwang@twopensource.com>
Subject: Re: PANIC in vxlan <debugging now>
Date: Thu, 16 Jan 2014 20:24:18 -0800
Message-ID: <CAHA+R7NWMu_w1f+6Fh3kx+95-+VgsqqXKAdx=pzwqmYK6E3nKg@mail.gmail.com>
References: <20140116171428.00004da1@unknown>
	<20140116180318.00004f53@unknown>
	<CAHA+R7N-FbNVSY-fjObfSrzc3UFMdAT-h-TPnX09EuA4R79U0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:63898 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbaAQEYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 23:24:20 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so964371lbv.24
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 20:24:18 -0800 (PST)
In-Reply-To: <CAHA+R7N-FbNVSY-fjObfSrzc3UFMdAT-h-TPnX09EuA4R79U0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 7:47 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Thu, Jan 16, 2014 at 6:03 PM, Jesse Brandeburg
> <jesse.brandeburg@intel.com> wrote:
>>
>> It appears that the bug is in acaf4e70997f (net: vxlan: when lower dev
>> unregisters remove vxlan dev as well).
>>
>> reverting that patch avoids the panic.  I wasn't able to see
>> immediately what was wrong in the patch.
>
> It seems vxlan pernet ops is run after loopback register.
>
> Please try the attached (totally untested) patch?

Never mind, I already verified it by myself.
A formal patch was just sent out.
