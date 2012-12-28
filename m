From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Fri, 28 Dec 2012 12:58:01 +0100
Message-ID: <20121228115801.GA20120@1984>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
 <CAFFEFTXT_fkF2pPSxDEEgic80NVWLqBWtFuvs6W9uDUW2aCnqw@mail.gmail.com>
 <87ip7mlr2r.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: canqun zhang <canqunzhang@gmail.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87ip7mlr2r.fsf@xmission.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 27, 2012 at 08:48:44PM -0800, Eric W. Biederman wrote:
[...]
> Does anyone know why Alexy decided to do this only for init_net?

Not myself.

[...]
> My inclination is that Gao Feng is on the rigt path by just removing
> the strange init_net special case and performing the work once
> per module load, and once per module unload.

That makes sense to me, I'll check Gao's patchset asap to come back to
him with some feedback. Thanks.
