From: Felix von Leitner <felix-linuxkernel@fefe.de>
Subject: Re: bizarre network timing problem
Date: Thu, 18 Oct 2007 00:00:19 +0200
Message-ID: <20071017220019.GA22765@codeblau.de>
References: <20071017205127.GA21334@codeblau.de> <47167BDE.4000103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760206AbXJQWAd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47167BDE.4000103@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thus spake Chuck Ebbert (cebbert@redhat.com):
> > Any ideas what could cause this?
> (cc: netdev)

Maybe I should mention this, too:

accept(5, {sa_family=AF_INET6, sin6_port=htons(59821), inet_pton(AF_INET6, "::ffff:127.0.0.1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [18446744069414584348]) = 8
setsockopt(8, SOL_TCP, TCP_NODELAY, [1], 4) = 0

And if it would be the Nagle algorithm, it should also impact the
ethernet case.

Felix
