From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: r8169 MAC addresses broken
Date: Tue, 28 Oct 2008 14:45:27 +0100
Message-ID: <m3mygozvd4.fsf@maximus.localdomain>
References: <490380C8.6070003@simon.arlott.org.uk>
	<4903947A.3060206@gmail.com>
	<20081025223443.GA30913@electric-eye.fr.zoreil.com>
	<4904A7C5.7090801@gmail.com>
	<20081026174654.GB24790@electric-eye.fr.zoreil.com>
	<4906E4BE.9050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59932 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120AbYJ1Np3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 09:45:29 -0400
In-Reply-To: <4906E4BE.9050304@gmail.com> (Jiri Slaby's message of "Tue\, 28 Oct 2008 11\:09\:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jirislaby@gmail.com> writes:

>> Same thing if you unplug the battery ?
>
> Thanks, now it seems to be OK.

Well, perhaps reverting that patch was a bit premature?

If removing battery fixes the problem then it's not the EEPROM.
Perhaps the chip can go into some VPD-zeroed state? The first
32-bits corruption seems unrelated to the patch, it still needs
bisecting or debugging, right?
-- 
Krzysztof Halasa
