From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Tue, 24 May 2005 02:34:41 -0400
Message-ID: <4292CB01.6090506@pobox.com>
References: <4292BA66.8070806@pobox.com> <Pine.LNX.4.58.0505232253160.2307@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0505232253160.2307@ppc970.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> I don't understand why you don't use different trees, like you did with
> BK. You can share the object directory with the different trees, but the

You really can't beat

	cp .git/refs/heads/master .git/refs/heads/new-branch

as the fastest way to create a new branch off the tip.

	Jeff
