From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 3/3] tc: cleanup tc_classify
Date: Tue, 21 Apr 2015 22:05:48 -0700
Message-ID: <CAHA+R7OSVs1rYcXkOM=FYoDMHGM30iWRRAVtdiJmU7jz9GRdYw@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:34418 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbbDVFFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 01:05:49 -0400
Received: by wgso17 with SMTP id o17so234349196wgs.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 22:05:48 -0700 (PDT)
In-Reply-To: <1429644476-8914-4-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> introduce tc_classify_act() and qdisc_drop_bypass() helper functions to reduce
> copy-paste among different qdiscs


I don't think qdisc_drop_bypass() is more readable than without it,
maybe you need a better name, or just leave the code as it is.

tc_classify_act() seems ok.
