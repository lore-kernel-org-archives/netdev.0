From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Mon, 22 Apr 2013 17:32:22 -0700
Message-ID: <5175D696.8060603@zytor.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:53923 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab3DWAco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 20:32:44 -0400
In-Reply-To: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2013 05:15 PM, Linus Torvalds wrote:
> 
> (It turns out that any use of "UINT_MAX" for a "long" value also results in
> this warning, because we define it as "~0ul", so there are other cases of
> spurious things where we *intentionally* drop the high bits).
> 

I'm responsible for this particular piece of drain bramage... we should
probably just open-code the correct types conditional on the sizes like
userspace does.

	-hpa
