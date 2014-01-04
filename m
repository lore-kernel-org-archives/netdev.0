From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26
 kernel
Date: Sat, 4 Jan 2014 13:34:17 -0800
Message-ID: <20140104133417.5d67c179@nehalam.linuxnetplumber.net>
References: <CAMBtn_2fjONQk0aO6MBy3j9X__78CTon_aYzJWCjouKnZDXEMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Asi Lichtenstein <asili22@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:53590 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaADVeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:34:24 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so16941927pab.6
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:34:23 -0800 (PST)
In-Reply-To: <CAMBtn_2fjONQk0aO6MBy3j9X__78CTon_aYzJWCjouKnZDXEMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jan 2014 15:24:34 +0200
Asi Lichtenstein <asili22@gmail.com> wrote:

> Hi there,
> 
> I need to add such support.
> How would you recommend me adding such support?
> 
> Is there a patch I could use?
> 
> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


First, 2.6.16 is 8 years old.
Second, by now there are 100's of known vulnerabilities; such a system
 would be a sitting duck for remote exploitation.
Third, multiple route tables in Linux was implemented much earlier
 than that, back in the 2.4 development. It is probably in the 2.6.16
 kernel. Most likely the vendor config or tools you have are broken
 and don't allow access to it.
