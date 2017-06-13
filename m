From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Tue, 13 Jun 2017 21:08:45 +1000
Message-ID: <20170613210845.24115319@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Ashwanth Goli <ashwanth@codeaurora.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc44x_defconfig) produced this warning:

net/core/dev.c: In function 'dev_cpu_dead':
net/core/dev.c:8330:2: warning: 'remsd' is used uninitialized in this function [-Wuninitialized]
  net_rps_send_ipi(remsd);
  ^

Introduced by commit

  773fc8f6e8d6 ("net: rps: send out pending IPI's on CPU hotplug")

These builds have CONFIG_RPS not set.

-- 
Cheers,
Stephen Rothwell
