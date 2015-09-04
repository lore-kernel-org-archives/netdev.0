From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Linux 4.2-rc8+] circular locking dependency detected: [pppd]
 ppp_dev_uninit() | rtnl_lock()
Date: Fri, 4 Sep 2015 22:32:23 +0200
Message-ID: <CA+icZUWDoqGoqBR=4ZFVjN9mLNmxM8Rmft9AFhTx3D6BtoJtLQ@mail.gmail.com>
References: <CA+icZUWo7MWeHvRMHZy8kGhSjZ=CbOEaHjgFba4FCGZ1FPqDHQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUWo7MWeHvRMHZy8kGhSjZ=CbOEaHjgFba4FCGZ1FPqDHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Could this be caused by this commit...?
>
> commit 8cb775bc0a34dc596837e7da03fd22c747be618b
> "ppp: fix device unregistration upon netns deletion"
>

With the Revert "ppp: fix device unregistration upon netns deletion" I
do not see any lockdep issues.

- Sedat -
