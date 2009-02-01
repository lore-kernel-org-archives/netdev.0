From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: 2.6.29-rc: unable to compile e100 firmware into kernel
Date: Sun, 1 Feb 2009 11:05:43 -0800
Message-ID: <4807377b0902011105l29e846c3r140212ac654efb93@mail.gmail.com>
References: <200901311900.00851.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:14834 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbZBATFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 14:05:44 -0500
In-Reply-To: <200901311900.00851.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2009 at 7:59 AM, Andrey Borzenkov <arvidjaar@mail.ru> wrote:
> {pts/2}% LC_ALL=C make -C ~/src/linux-git O=$HOME/build/linux-2.6.29
> make: Entering directory `/home/bor/src/linux-git'
>  Using /home/bor/src/linux-git as source for kernel
> ln -fsn /home/bor/src/linux-git source

I think (seem to recall something on the list) there have been
multiple people reporting the make O= option doesn't work with
CONFIG_FIRMWARE_IN_KERNEL, but what does the
CONFIG_PREVENT_FIRMWARE_BUILD=y option do?  If it does what it appears
to by its title, looks like you might need to set that to =n
