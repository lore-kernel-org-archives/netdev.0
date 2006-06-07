From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 14:46:22 -0500
Message-ID: <44872D0E.6010206@lwfinger.net>
References: <4485D66B.7080108@lwfinger.net> <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net> <1149695470.3925.7.camel@johannes> <1149695859.3925.11.camel@johannes> <1149701352.2625.20.camel@localhost.localdomain> <44871723.3040803@lwfinger.net> <1149708987.2625.114.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:54526 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932398AbWFGTq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 15:46:27 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1149708987.2625.114.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> Weird, does the kernel not do something that fprintf() _does_ do here?
> I tested with a short C program that mimics the behavior of this chunk
> of code, and "%.2x" didn't work, but "%.2hhx" certainly did.  "hh" is
> supposed to mean "A following integer conversion corresponds to a signed
> char or unsigned char argument".  The original conversion was converting
> stuff from la-la land after the first 4 bytes (in both softmac and my
> testcase), and "hh" solved it in the testcase.  I did try casting to
> char, but glibc pretty much ignored that.

I also found that casting with char gave the same result as no cast, but that a u8 cast worked. I 
guess printk is _almost_ like fprintf.

Larry

