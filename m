From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: don't remove address state on ifdown if
 the address is being kept
Date: Fri, 5 Nov 2010 14:45:28 +0800
Message-ID: <AANLkTine2qXg7MTFyh=Ka=tB8fuzB18-NVRryTyc=LKp@mail.gmail.com>
References: <AANLkTimyqFoUvjQM_qLS2YeVmJQ_6-LJc6KfLVE-mzH3@mail.gmail.com> <AANLkTimLicmgC3BptZvXGoA0aN6-cFJtRG3DpqJ3NTpJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:6616 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab0KEGpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 02:45:51 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oA56johx006334
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 23:45:50 -0700
Received: from gyf2 (gyf2.prod.google.com [10.243.50.66])
	by hpaq2.eem.corp.google.com with ESMTP id oA56jdtV021465
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 23:45:49 -0700
Received: by gyf2 with SMTP id 2so2299431gyf.7
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 23:45:48 -0700 (PDT)
In-Reply-To: <AANLkTimLicmgC3BptZvXGoA0aN6-cFJtRG3DpqJ3NTpJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 2:45 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
>> Fix it so that none of this state is updated if the address is being kept on the interface.

David, any feedback on this? The existing code clearly has the
intention of keeping the addresses around, except they don't actually
work, and this just fixes the bug.

Thanks,
Lorenzo
