From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Thu, 27 Jan 2011 07:55:48 -0800
Message-ID: <AANLkTint1T36oyj0R4rFPN6sewBxdNkz5xzHvWK-rq-0@mail.gmail.com>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: therbert@google.com, netdev@vger.kernel.org
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:4351 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab1A0Pzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 10:55:52 -0500
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p0RFto9k023433
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 07:55:50 -0800
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by wpaz5.hot.corp.google.com with ESMTP id p0RFtQBB008221
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 07:55:49 -0800
Received: by qyl38 with SMTP id 38so6658268qyl.18
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 07:55:48 -0800 (PST)
In-Reply-To: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 02:07, Daniel Baluta <daniel.baluta@gmail.com> wrote:
> How did you solved the issue regarding scaling TCP listeners?
> I think SO_REUSEPORT proposed by patch [1] can be a good
> start. Where there any follow ups?

Google is using the patch internally.  I've recently joined google and
have picked up this work from Tom; I'm starting to rework how it
interacts with TCP (in particular, changing how it interacts with
request sockets and listen sockets so that incoming connections are
not prematurely bound to a specific listener sharing the port).  I
have nothing worth sharing yet.
