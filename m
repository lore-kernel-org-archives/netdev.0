From: Neal Cardwell <ncardwell@google.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:3418
Date: Tue, 6 Mar 2012 00:46:28 -0500
Message-ID: <CADVnQyk_6LYW2nyjccWjv1NmjivXf5cXBqJ+LsZLjGyOj7kddQ@mail.gmail.com>
References: <alpine.DEB.2.01.1202261556150.4930@trent.utfs.org>
	<alpine.DEB.2.01.1202290929520.4930@trent.utfs.org>
	<CADVnQy=JkVc_8ptpSkhQWe4HJpbe_+JMad+2uqgN1iUfkfFFCw@mail.gmail.com>
	<CADVnQykqaUCFBYXVqGNq+HmeowAbYJQQNpbXFpQ4Uif3gwf4ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, markus@trippelsdorf.de,
	LKML <linux-kernel@vger.kernel.org>
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQykqaUCFBYXVqGNq+HmeowAbYJQQNpbXFpQ4Uif3gwf4ig@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 29, 2012 at 12:41 PM, Christian Kujau <lists@nerdbynature.d=
e> wrote:
> This is still happening with 3.3.0-rc5, .config & dmesg here:
>
> =A0 http://nerdbynature.de/bits/3.3.0-rc4/ipv4/

I was finally able to reproduce this issue where there are warnings
about sacked_out going negative (since 3.3.0-rc4), and my testing
shows that this patch seems to fix the issue:

  http://patchwork.ozlabs.org/patch/144844/

=46or folks who were seeing this problem and are so inclined, feel free
to try the latest 3.3-rc6 kernel (or davem's "net" tree in git, if
that's easier) with that patch applied, and let me know how it goes.

thanks,
neal
