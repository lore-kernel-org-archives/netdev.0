From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Sat, 11 Apr 2015 08:53:48 +0200
Message-ID: <5528C4FC.5020207@iogearbox.net>
References: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47218 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbbDKGx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 02:53:59 -0400
In-Reply-To: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2015 02:45 AM, Cong Wang wrote:
...
> The problem you try to solve is kernel's implementation problem,
> users should not care, so we should make some effort to make ingress
> align with egress, rather than making more differences.

I guess you've followed the previous discussion up to this point,
and are aware that we cannot break some users f.e. such as u32.
There has been thought put into this and we went back and forth,
if you have a better suggestion on how to get it resolved properly
and generically, I'm all for it.
