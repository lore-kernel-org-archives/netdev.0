From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [net-next v2 03/13] net: remove inet6_reqsk_alloc
Date: Wed, 25 Jun 2014 21:04:07 +0300
Message-ID: <CAE1zotKQDf5tks+_tnnP_40wOhu2faXL5b7dgX8p3suP4V8d_Q@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-4-git-send-email-octavian.purdila@intel.com>
	<CAHA+R7MzWDbZNMbFkBigeWAYM+=Yo=VyHqRD9dgiE1Q3r0XAWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:47677 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757651AbaFYSEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 14:04:09 -0400
Received: by mail-wi0-f170.google.com with SMTP id cc10so8140334wib.5
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 11:04:08 -0700 (PDT)
In-Reply-To: <CAHA+R7MzWDbZNMbFkBigeWAYM+=Yo=VyHqRD9dgiE1Q3r0XAWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 8:59 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Wed, Jun 25, 2014 at 7:09 AM, Octavian Purdila
> <octavian.purdila@intel.com> wrote:
>> Since pktops is only used for IPv6 only and opts is used for IPv4
>> only, we can move these fields into a union and this allows us to drop
>> the inet6_reqsk_alloc function as after this change it becomes
>> equivalent with inet_reqsk_alloc.
>>
>
> Or use kmem_cache_zalloc() so that inet_reqsk_alloc() doesn't have
> to init ->opt to NULL explicitly.

Wouldn't that be costly?
