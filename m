From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Thu, 23 Apr 2015 11:12:29 -0700
Message-ID: <CAHA+R7N0w0gSVRrxchzHoYHV6=ubs7m1CW6G+e-G3+sBbnz+yQ@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-3-git-send-email-ast@plumgrid.com>
	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>
	<55381F14.4070708@plumgrid.com>
	<CAHA+R7Mz0LSZ-S=k7rvUuhXm+GT9w2ve6Ug+YPJ4vqnsrLnfpw@mail.gmail.com>
	<55385D0B.5030103@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34095 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030390AbbDWSMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:12:31 -0400
Received: by wgso17 with SMTP id o17so27112207wgs.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:12:29 -0700 (PDT)
In-Reply-To: <55385D0B.5030103@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 7:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>
> TC_ACT_QUEUED cannot be removed.
> Only deprecated with backwards compatibility the way this patch did it.
> That should have been obvious.
>

It is at least the third time I have to repeat that: we really don't care
about out-of-tree modules.

Everyone MUST read Documentation/stable_api_nonsense.txt.
