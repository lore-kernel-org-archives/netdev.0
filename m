From: Dan Williams <dcbw@redhat.com>
Subject: Re: rfkill-input to be removed
Date: Thu, 21 Apr 2011 10:51:35 -0500
Message-ID: <1303401097.16512.17.camel@dcbw.foobar.com>
References: <4DAFEAA7.5090003@absence.it> <4DB03586.3040702@absence.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: Marco Chiappero <marco@absence.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604Ab1DUPuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 11:50:12 -0400
In-Reply-To: <4DB03586.3040702@absence.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 15:47 +0200, Marco Chiappero wrote:
> Il 21/04/2011 10:28, Marco Chiappero ha scritto:
> > Please remove that code as soon as possible, rfkill input events should
> > be handled by user space tools.
> 
> About this topic, I've created a patch right now, you can find it here:
> http://www.absence.it/vaio-acpi/source/patches/rfkill-input.patch
> Does it look fine?

You'll want to follow the patch submission guidelines:

http://linux.yyz.us/patch-format.html

before people will look at the patch, because many of the people who
would look at it are quite busy.  That means:

1) use a subject like "[PATCH] rfkill-input: remove deprecated module"
2) Add your Signed-off-by: Your Name <your email>
3) paste your patch *inline*, not as an attachment, and make *sure* to
use the "preformat" or whatever option when you do, so that your mailer
doesn't wrap long lines

Dan

> Moreover, using checkpatch.pl I've found 3 coding style errors, I'm 
> attaching a patch to fix them (apply this one first).
> 
> And just one last thing: as there is no configuration option inside the 
> menu, shouldn't we change the "menuconfig RFKILL" line to "config 
> RFKILL" inside net/rfkill/Kconfig?


