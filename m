From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] netfilter: undefined reference to 'nf_conntrack_tstamp_*'
Date: Thu, 20 Jan 2011 12:05:32 -0800
Message-ID: <4D38958C.7090101@intel.com>
References: <20110120191612.24205.73463.stgit@jf-dev1-dcblab> <4D389283.3040307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pablo@netfilter.org" <pablo@netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D389283.3040307@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/20/2011 11:52 AM, Patrick McHardy wrote:
> Am 20.01.2011 20:16, schrieb John Fastabend:
>> net/built-in.o: In function `nf_conntrack_init_net':
>> net/netfilter/nf_conntrack_core.c:1521:
>> 	undefined reference to `nf_conntrack_tstamp_init'
>> net/netfilter/nf_conntrack_core.c:1531:
>> 	undefined reference to `nf_conntrack_tstamp_fini'
>>
>> Add 'selects' notation to Kconfig to include NF_CONNTRACK_TIMESTAMP
>> this resolves all the config files I tested.
> 
> That's not the correct fix, NF_CONNTRACK_TIMESTAMP is supposed
> to be option. Please try whether this patch fixes the problem.
> 

You patch fixes this thanks!
