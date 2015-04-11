From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Fri, 10 Apr 2015 18:39:06 -0700
Message-ID: <55287B3A.50103@plumgrid.com>
References: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33713 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbbDKBjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:39:08 -0400
Received: by paboj16 with SMTP id oj16so38213863pab.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:39:08 -0700 (PDT)
In-Reply-To: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/15 5:45 PM, Cong Wang wrote:
>
> The problem you try to solve is kernel's implementation problem,
> users should not care, so we should make some effort to make ingress
> align with egress, rather than making more differences.

Agree. I already tried to do this unconditionally in v2.
Folks have raised concerns that it may break some tc modules
and in general doesn't work for all types of netdevs that don't
set headers_ops. So this flag is the safe compromise.
Personally I will be always turning it on.
