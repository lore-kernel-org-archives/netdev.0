From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [Patch 3/3] net: reserve ports for applications using fixed port numbers
Date: Tue, 13 Apr 2010 09:32:22 -0700
Message-ID: <21DAC78125424ED291B5D6477CFF9657@amr.corp.intel.com>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>	<4BC41994.7030707@redhat.com>	<4BC42FE0.4040601@redhat.com> <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <opurdila@ixiacom.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>, <ebiederm@xmission.com>,
	<linux-kernel@vger.kernel.org>
To: "'Tetsuo Handa'" <penguin-kernel@I-love.SAKURA.ne.jp>,
	<amwang@redhat.com>, <rolandd@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Sean and Roland, is below patch correct?
>inet_is_reserved_local_port() is the new function proposed in this patchset.

It looks correct to me.  I didn't test the patch series, but if I comment out
the call to inet_is_reserved_local_port() in the provided below, the changes
worked fine for me.

Acked-by: Sean Hefty <sean.hefty@intel.com>
