From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ksoftirqd high cpu load on kernels 2.6.24 to 2.6.27-rc1-mm1
Date: Thu, 7 Aug 2008 20:58:02 +0200
Message-ID: <20080807185802.GA16327@electric-eye.fr.zoreil.com>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no> <48975BD3.6040709@shaw.ca> <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Hancock <hancockr@shaw.ca>, netdev@vger.kernel.org
To: Dushan Tcholich <dusanc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36272 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752629AbYHGS6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 14:58:10 -0400
Content-Disposition: inline
In-Reply-To: <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dushan Tcholich <dusanc@gmail.com> :
[...]
> I googled a little and found out that oprofile is a little above my head.
> So as I thought that some driver or HW might be responsible for this I
> tried to disable various onboard HW and found out that if I disable
> onboard ethernet problem dissapears, so now I've added netdev and
> maintainer of R8169 driver to cc.

Can you try 2.6.27-rc2 and send the content of /proc/interrupts, dmesg,
ifconfig as well as a capture of the strange output from top ?

It seems rather benign though.

-- 
Ueimor
