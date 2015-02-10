From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 08:33:27 -0800
Message-ID: <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
	<20150209.205209.1524645061817000265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:46356 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbBJQd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 11:33:28 -0500
In-Reply-To: <20150209.205209.1524645061817000265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 9, 2015 at 8:52 PM, David Miller <davem@davemloft.net> wrote:
>
> I think the handling of the 'used' local variable for function
> skcipher_recvmsg() in that commit is suspect.

Yeah, skcipher_wait_for_data() waits for it to be non-zero, but it's
not reloaded.

Will try your suggestion,

                        Linus
