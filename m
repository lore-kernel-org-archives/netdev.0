From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 11:18:30 -0600
Message-ID: <4F0F15E6.30301@lwfinger.net>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com> <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com> <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com> <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com> <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com> <4F0E5E57.9060204@lwfinger.net> <4F0EDC75.3040003@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49766 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab2ALRSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 12:18:33 -0500
Received: by ggdk6 with SMTP id k6so1108141ggd.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 09:18:33 -0800 (PST)
In-Reply-To: <4F0EDC75.3040003@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2012 07:13 AM, Arend van Spriel wrote:
>
> I am surprised that we end up on sprom_read_pci(). That suggests that
> MacBook Air has an external sprom. Can you tell me what the function
> ai_is_sprom_available() returns on your system?

For completeness, sromctrl is 0x12, thus bit 1 (SRC_PRESENT) is not set, and my 
device has an OTP, not an SPROM.

I do not see anything wrong with commit 888153b3db3f, but I realize that my card 
really does not test any of those changes.

Larry
