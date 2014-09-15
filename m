From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] rhashtable: Remove gfp_flags from insert and remove
 functions
Date: Mon, 15 Sep 2014 07:49:56 -0700
Message-ID: <1410792596.7106.166.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1410782841.git.tgraf@suug.ch>
	 <bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
	 <1410784535.7106.164.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140915124937.GB21541@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140915124937.GB21541@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-15 at 13:49 +0100, Thomas Graf wrote:

> Agreed. Will introduce this through a table parameter option when
> converting the inet hash table.

I am not sure you covered the /proc/net/tcp problem yet ? (or inet_diag)
