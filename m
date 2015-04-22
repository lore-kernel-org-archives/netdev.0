From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Wed, 22 Apr 2015 09:43:56 +0200
Message-ID: <5537513C.504@iogearbox.net>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com> <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56468 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbDVHoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:44:12 -0400
In-Reply-To: <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 07:02 AM, Cong Wang wrote:
> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> TC_ACT_QUEUED was always an alias of TC_ACT_STOLEN.
>> Get rid of redundant checks in all qdiscs.
>> Instead do it once.
>
> The current code can be easily extended, while your code not.

So, do you plan to extend it ?

The alias has been there since pre-git times, so more than
10 years now, where no-one felt the need to extended the
semantics of it ...
