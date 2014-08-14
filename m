From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Intel wireless microcode problem..
Date: Thu, 14 Aug 2014 10:42:08 -0500
Message-ID: <53ECD8D0.4050709@lwfinger.net>
References: <CA+55aFxdt-9e9X0EYCu2Ku8sSTspUGPk5qKa72XH63zrkdPthw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:54866 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134AbaHNPmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 11:42:10 -0400
In-Reply-To: <CA+55aFxdt-9e9X0EYCu2Ku8sSTspUGPk5qKa72XH63zrkdPthw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 10:05 AM, Linus Torvalds wrote:
> Ok, so it seems the current merge window introduces some horrid intel
> microcode problem, because I don't seem to see this with 3.16. But
> maybe that's just happenstance.
> 
> Any ideas? This fills up all the logs etc.
> 
>                       Linus

Linus,

There is a new firmware that seems to help the problem. You can get it from
Emmanuel's git clone. As he wrote earlier

==========================

We released an experimental firmware for 3160 / 7260 / 7265.

It is available from my linux-firmware.git clone:

3160:
https://git.kernel.org/cgit/linux/kernel/git/egrumbach/linux-firmware.git/plain/iwlwifi-3160-9.ucode?h=Core6
7260:
https://git.kernel.org/cgit/linux/kernel/git/egrumbach/linux-firmware.git/plain/iwlwifi-7260-9.ucode?h=Core6
7265:
https://git.kernel.org/cgit/linux/kernel/git/egrumbach/linux-firmware.git/plain/iwlwifi-7265-9.ucode?h=Core6

We had an issue with the version number in this stream, so I can't release it
officially, nor can I send a pull request to integrate it to linux-firmware.git.
I am working with the firmware team to fix the version issue.
I still would be glad to have more testing on this firmware, so any feedback
would be greatly appreciated.
It has gone through our regular testing cycles, but "field" feedback is always
valuable.

Thanks in advance to anyone who will test it.

New (temporary) version number: 25.223.9.0

============================================


Larry
