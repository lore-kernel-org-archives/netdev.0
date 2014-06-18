From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net] b58537a1f56: +89.2% netperf.Throughput_Mbps
Date: Wed, 18 Jun 2014 22:38:49 +0200
Message-ID: <53A1F8D9.7070704@redhat.com>
References: <53A10291.7090301@intel.com> <alpine.DEB.2.02.1406181328160.10339@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jet Chen <jet.chen@intel.com>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, lkp@01.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1406181328160.10339@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/18/2014 10:29 PM, David Rientjes wrote:
> On Wed, 18 Jun 2014, Jet Chen wrote:
>
>> Hi Daniel,
>>
>> FYI, we noticed the below changes on
>>
>> commit b58537a1f5629bdc98a8b9dc2051ce0e952f6b4b ("net: sctp: fix permissions
>> for rto_alpha and rto_beta knobs")
>
> There's no way this is legitimate, that commit cannot possibly affect the
> performance of netperf.  I wouldn't bother to spend any time investigating
> this.

One assumption could be that netperf was setting this knob
internally and ignoring the result of it (error/success), but
that we might need to look up in netperf source to confirm.

Cheers,

Daniel
