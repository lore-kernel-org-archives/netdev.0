From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next v2 03/13] net: remove inet6_reqsk_alloc
Date: Wed, 25 Jun 2014 10:59:43 -0700
Message-ID: <CAHA+R7MzWDbZNMbFkBigeWAYM+=Yo=VyHqRD9dgiE1Q3r0XAWA@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-4-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:54000 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757623AbaFYR7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 13:59:44 -0400
Received: by mail-lb0-f182.google.com with SMTP id c11so2133867lbj.27
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 10:59:43 -0700 (PDT)
In-Reply-To: <1403705402-14388-4-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 7:09 AM, Octavian Purdila
<octavian.purdila@intel.com> wrote:
> Since pktops is only used for IPv6 only and opts is used for IPv4
> only, we can move these fields into a union and this allows us to drop
> the inet6_reqsk_alloc function as after this change it becomes
> equivalent with inet_reqsk_alloc.
>

Or use kmem_cache_zalloc() so that inet_reqsk_alloc() doesn't have
to init ->opt to NULL explicitly.
