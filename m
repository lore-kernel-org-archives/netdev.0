From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/5] rhashtable: Remove gfp_flags from insert and remove
 functions
Date: Mon, 15 Sep 2014 15:56:25 +0100
Message-ID: <20140915145625.GE21541@casper.infradead.org>
References: <cover.1410782841.git.tgraf@suug.ch>
 <bd3aa4282e89b022620225101ab491e344852f5f.1410782841.git.tgraf@suug.ch>
 <1410784535.7106.164.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140915124937.GB21541@casper.infradead.org>
 <1410792596.7106.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410792596.7106.166.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/14 at 07:49am, Eric Dumazet wrote:
> On Mon, 2014-09-15 at 13:49 +0100, Thomas Graf wrote:
> 
> > Agreed. Will introduce this through a table parameter option when
> > converting the inet hash table.
> 
> I am not sure you covered the /proc/net/tcp problem yet ? (or inet_diag)

I haven't digged through inet_diag in all detail yet but was planning to
acquire ht->mutex to block expansions and then take bucket locks during
bucket traverals as done now. I will do that next but wanted to get this
out for comments in the meantime.
