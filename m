From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Tue, 21 Apr 2015 22:02:03 -0700
Message-ID: <CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36919 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbbDVFCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 01:02:04 -0400
Received: by widdi4 with SMTP id di4so43715901wid.0
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 22:02:03 -0700 (PDT)
In-Reply-To: <1429644476-8914-3-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> TC_ACT_QUEUED was always an alias of TC_ACT_STOLEN.
> Get rid of redundant checks in all qdiscs.
> Instead do it once.

The current code can be easily extended, while your code not.
I don't see the need of this change.
