From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2 v6] net: ipv4 sysctl option to ignore routes
 when nexthop link is down
Date: Tue, 23 Jun 2015 13:20:33 -0400
Message-ID: <20150623172028.GT588@gospo.home.greyhouse.net>
References: <1435074711-924-1-git-send-email-gospo@cumulusnetworks.com>
 <1435074711-924-3-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bB22KZjRFW1N70moF0Zm3biW8YgKzJeFWU+noT8BeSASA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:33719 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbbFWRUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 13:20:36 -0400
Received: by qcbcf1 with SMTP id cf1so4743815qcb.0
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 10:20:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bB22KZjRFW1N70moF0Zm3biW8YgKzJeFWU+noT8BeSASA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 09:30:15AM -0700, Scott Feldman wrote:
> On Tue, Jun 23, 2015 at 8:51 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > This feature is only enabled with the new per-interface or ipv4 global
> > sysctls called 'ignore_routes_with_linkdown'.
> 
> [cut]
> 
> checkpatch.pl says:
> 
> WARNING: suspect code indent for conditional statements (16, 20)
> #293: FILE: net/ipv4/fib_semantics.c:1047:
> +               if (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN) {
> +                   in_dev = __in_dev_get_rcu(fi->fib_nh->nh_dev);

Good catch, Scott.  I saw this one, but mistakenly looked at the lines
around it and thought I was following the style in the file.  v7 coming
soon.
