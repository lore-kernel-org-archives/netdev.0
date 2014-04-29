From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/5] netfilter: Fix format string mismatch in
 mangle_content_len()
Date: Tue, 29 Apr 2014 21:02:46 +0200
Message-ID: <20140429190246.GA9993@localhost>
References: <1396280619-31152-1-git-send-email-standby24x7@gmail.com>
 <20140429142119.GA12499@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140429142119.GA12499@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2014 at 03:21:21PM +0100, Patrick McHardy wrote:
> On Tue, Apr 01, 2014 at 12:43:36AM +0900, Masanari Iida wrote:
> > Fix format string mismatch in mangle_connect_len()
> 
> All these patches seem like pointless noise to me. In none of these
> cases can the value legitimately be negative. If anything, you should
> fix the types to be unsigned.

Let's do that instead. I'm going to remove these oneliners from the
nf-next queue, thanks Patrick.
