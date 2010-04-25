From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: 2.6.34-rc5+: oops in IPv6
Date: Sun, 25 Apr 2010 23:58:32 +0900
Message-ID: <201004252358.EHF35423.FHOVJOtLMOFFQS@I-love.SAKURA.ne.jp>
References: <z2if861ec6f1004250745u94892bdbw9b17db4be57b131b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: manuel.lauss@googlemail.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <z2if861ec6f1004250745u94892bdbw9b17db4be57b131b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Manuel Lauss wrote:
> 2.6.34-rc5-00204-gddc9b34  dies when sshd (openssh 5.5) is started
> Last pull I made on April 23 was fine.

This seems a regression introduced while handling
"PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open hugeamount of outgoing connections (unable to bind ... )"
problem. It is in https://bugzilla.kernel.org/show_bug.cgi?id=15847 .

Regards.
