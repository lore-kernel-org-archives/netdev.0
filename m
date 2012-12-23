From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 04:14:39 +0100
Message-ID: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

after reading the thread "Regression in 3.8-rc1: "BUG: sleeping
function called from invalid context"" [1] I decided to pull-in
net.git#master (up to commit 9b1536c490d5: "bridge: call
br_netpoll_disable in br_add_if") on top of Linus upstream.

With this kernel I can't neither ping my router nor does DNS work.
IIRC there were 6 commits, not sure which of them is culprit.

I tried the v3.8-rc1-raring from [2] which works nicely here on
Ubuntu/precise AMD64.
Can't say if NetworkManager is involved or not.

Any feedback appreciated, Thanks.

Regards,
- Sedat -

[1] https://lkml.org/lkml/2012/12/22/79
[2] http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.8-rc1-raring/
