From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] eeprom_93cx6: Add write support
Date: Thu, 21 Dec 2006 19:54:06 +0100
Message-ID: <200612211954.08123.IvDoorn@gmail.com>
References: <200612131956.51000.IvDoorn@gmail.com> <20061213190651.GF26412@csclub.uwaterloo.ca> <a32f33a40612202322v349caae9j9078bb590239c999@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>,
	netdev@vger.kernel.org, "Michael Wu" <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:41200 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423012AbWLUSyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 13:54:37 -0500
Received: by nf-out-0910.google.com with SMTP id o25so3143083nfa
        for <netdev@vger.kernel.org>; Thu, 21 Dec 2006 10:54:35 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <a32f33a40612202322v349caae9j9078bb590239c999@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > This patch addes support for writing to the eeprom,
> > this also moves some duplicate code into seperate functions.
> 
> John: Do you want me to merge this path with the eeprom merge patch,
> and move the patch that moves rt2x00 to use this eeprom module into a
> separate patch or all these 2 patches good enough?

I shouldn't write mails while tired. Let met explain myself. ;)
eeprom_93cx6 has now 2 patches pending:
 1 - move eeprom_93cx6 out of rt2x00 and into /lib
 2 - add write support for eeprom_93cx6

Should patch 1 be split into a patch to add eeprom_93cx6
to the /lib folder and a seperate patch to remove the module
from rt2x00?

And while redoing the patch, merge patch 2 with the patch to add
eeprom_93cx6 to /lib?

Ivo
