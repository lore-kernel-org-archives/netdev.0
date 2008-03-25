From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek RTL-8169 having receive errors
Date: Tue, 25 Mar 2008 23:56:17 +0100
Message-ID: <20080325225617.GB2277@electric-eye.fr.zoreil.com>
References: <3aa654a40803241717g218f3d51pec42ecbb29835248@mail.gmail.com> <20080325221050.GA2277@electric-eye.fr.zoreil.com> <3aa654a40803251551ka5e6287uab79d99626e75ae2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Avuton Olrich <avuton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42078 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755405AbYCYXOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:14:25 -0400
Content-Disposition: inline
In-Reply-To: <3aa654a40803251551ka5e6287uab79d99626e75ae2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avuton Olrich <avuton@gmail.com> :
[...]
> shapeshifter ~ # ethtool -s eth1 msglvl 255
> Cannot set new msglvl: Operation not supported

See ethtool -i eth1 and figure which ethX is relevant for your r8169 :o)

[...]
> I can't even boot 2.6.23, so that's not doable. I will work on taking
> this machine down sometime this week, if it's possible and necessary.

Don't boot 2.6.23: compile its r8169 driver in a 2.6.22 tree.

Or simply revert d78ae2dcc2acebb9a1048278f47f762c069db75c with current
git (shot in the dark).

Good night.

-- 
Ueimor
