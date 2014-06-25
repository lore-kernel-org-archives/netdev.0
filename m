From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next v2 12/13] tcp: add queue_add_hash to tcp_request_sock_ops
Date: Wed, 25 Jun 2014 12:05:15 -0700
Message-ID: <CAHA+R7NYYdKs=TucJrk8PXMfed+br_pAWJckV4AjPKWziz3G_Q@mail.gmail.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
	<1403705402-14388-13-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:35433 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbaFYTFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 15:05:17 -0400
Received: by mail-lb0-f179.google.com with SMTP id z11so2191902lbi.10
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 12:05:15 -0700 (PDT)
In-Reply-To: <1403705402-14388-13-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 7:10 AM, Octavian Purdila
<octavian.purdila@intel.com> wrote:
> Add queue_add_hash member to tcp_request_sock_ops so that we can later
> unify tcp_v4_conn_request and tcp_v6_conn_request.
>


Alternatively, you can unify inet6_csk_reqsk_queue_hash_add() with
inet_csk_reqsk_queue_hash_add().
