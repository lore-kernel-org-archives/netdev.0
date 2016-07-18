From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 18:34:52 +0200
Message-ID: <CALx6S36vLAEN-ezqm7EHwwGE876troCkDkkQKhsmeTc4VH0E9w@mail.gmail.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc> <37D7C6CF3E00A74B8858931C1DB2F07712C1968E@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33779 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbcGRQfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:35:06 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so6378654ith.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 09:34:53 -0700 (PDT)
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07712C1968E@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 5:51 PM, Liang, Kan <kan.liang@intel.com> wrote:
>
>
>> >
>> > It is a big challenge to get good network performance. First, the
>> > network performance is not good with default system settings. Second,
>> > it is too difficult to do automatic tuning for all possible workloads,
>> > since workloads have different requirements. Some workloads may want
>> high throughput.
>>
>> Seems you did lots of tests to find optimal settings for a given base policy.
>>
> Yes. Current test only base on Intel i40e driver. The optimal settings should
> vary for other devices. But adding settings for new device is not hard.
>
The optimal settings are very dependent on system architecture (NUMA
config, #cpus, memory, etc.) and sometimes kernel version as well. A
database that provides best configurations across different devices,
architectures, and kernel version might be interesting; but beware
that that is a whole bunch of work to maintain, Either way policy like
this really should be handled in userspace.

Tom
