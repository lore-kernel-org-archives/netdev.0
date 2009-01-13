From: "Norman Rasmussen" <norman@rasmussen.co.za>
Subject: Re: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Tue, 13 Jan 2009 16:14:55 +0200
Message-ID: <5b698f5a0901130614w25863576jcdfc839e68daa45c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:60806 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbZAMOO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 09:14:58 -0500
Received: by bwz14 with SMTP id 14so67533bwz.13
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 06:14:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

re: http://marc.info/?l=linux-netdev&m=118415534518953
(please cc me on replies)

On 2007-07-11 Andreas Henriksson wrote:
> c) take the more painful route of switching over to 64bit statistics in
> netlink. Add 64bit interface, port userspace tools, deprecate the old 32bit
> interface. (I guess exporting as u64 even on 32bit architectures wouldn't
> hurt them, even if they still will rollover at (unsigned long) 32 bits.)

I youthfully opened a ticket here:
http://bugzilla.kernel.org/show_bug.cgi?id=12425 to track the
implementation for this feature request.

Is there someone more qualified than me to add support for 64 bit
device counters, or is this something I should try and hack together
in a UML and submit a patch?

--
- Norman Rasmussen
- Email: norman@rasmussen.co.za
- Home page: http://norman.rasmussen.co.za/
