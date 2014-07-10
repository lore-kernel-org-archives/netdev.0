From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: Adjust ptp event timestamps
Date: Thu, 10 Jul 2014 19:34:39 +0200
Message-ID: <20140710173439.GB7965@localhost.localdomain>
References: <1404901343-19445-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140709174149.GA3859@localhost.localdomain>
 <1404983629.2901.8.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:35131 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaGJRfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 13:35:04 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so9174707wgh.23
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 10:35:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404983629.2901.8.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 09:13:51AM +0000, S=F8rensen, Stefan wrote:
> This is not adjusting the packet timestamps but the gpio event
> timestamps - the ptp protocol is not involved here. Without this
> adjustment, looping back a pps signal from one gpio to another will
> result in a ~35ns offset.

Oops, sorry.
=20
> Then the end user will have to figure out what delay corrections need=
 to
> be made and configure the applications(s) to adjust for this. But I
> don't see any good solution to this either.=20

Yep, not so easy. I think it is only practical in a highly controlled
environment.

Thanks,
Richard
