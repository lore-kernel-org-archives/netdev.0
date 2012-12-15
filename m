From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net] sctp: jsctp_sf_eat_sack: fix jprobes function
 signature mismatch
Date: Sat, 15 Dec 2012 22:02:34 +0100
Message-ID: <CAD6jFUTtS+no6df5sawbYx1dDBwWeOcY69n3zjr3iy+mjnCbjw@mail.gmail.com>
References: <cover.1355602097.git.dborkman@redhat.com>
	<a910a63d58d95aed8caeea8a43a21cab863b3bfb.1355602097.git.dborkman@redhat.com>
	<50CCE017.2050407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58414 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2LOVCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 16:02:44 -0500
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1Tjysa-0002wN-Pa
	for netdev@vger.kernel.org; Sat, 15 Dec 2012 22:02:40 +0100
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TjysX-0001eq-Mv
	for netdev@vger.kernel.org; Sat, 15 Dec 2012 22:02:37 +0100
Received: by mail-ea0-f174.google.com with SMTP id e13so1819515eaa.19
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2012 13:02:34 -0800 (PST)
In-Reply-To: <50CCE017.2050407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2012 at 9:39 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 12/15/2012 03:12 PM, Daniel Borkmann wrote:
>>
>> Commit 24cb81a6a (sctp: Push struct net down into all of the
>> state machine functions) introduced the net structure into all
>> state machine functions, but jsctp_sf_eat_sack was not updated,
>> hence when SCTP association probing is enabled in the kernel,
>> any simple SCTP client/server program from userspace will panic
>> the kernel.
>
>
> Aha!!!  That makes a lot more sense...

Indeed. ;-)

> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>
> Thanks
