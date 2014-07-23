From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: Re: [PATCH 2/6] MIPS: Alchemy: move ethernet registers to ethernet driver
Date: Wed, 23 Jul 2014 17:41:23 +0200
Message-ID: <CAOLZvyEZLP=c1cgkp=szvJOEgfctGx16obPc+2KpG0fQ3hqQAA@mail.gmail.com>
References: <1406126186-471228-1-git-send-email-manuel.lauss@gmail.com>
 <1406126186-471228-3-git-send-email-manuel.lauss@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1727C2C8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:51514 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152AbaGWPmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 11:42:07 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so1370870wes.35
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 08:42:03 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727C2C8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 4:58 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Manuel Lauss
>> Move the register offsets and bit descriptions from the au1000.h header
>> to their only user, the au1000_eth.c driver.
>
> Personally I'd use 2 header files.
> One for the private data and one for the public data.
> It can be much easier to read code if the structure definitions are in
> a header file.

au1000.h now only contains core chip-specific code; this is the last
driver which
has driver-specific definitions living in the "chip-global" headers.
Eventually I'd like to get rid of au1000_eth.h as well :)

Manuel
