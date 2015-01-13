From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v2 02/12] net: flow_table: add flow, delete flow
Date: Tue, 13 Jan 2015 15:00:15 -0800
Message-ID: <CAADnVQK0FqxD9iu5UzFu0Pizi9tQPgjmAs3WBbV7y8jk0Sdi5w@mail.gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32> <20150113213556.13874.41211.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, simon.horman@netronome.com,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:47186 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbbAMXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 18:00:36 -0500
Received: by mail-qc0-f173.google.com with SMTP id i17so4843935qcy.4
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 15:00:35 -0800 (PST)
In-Reply-To: <20150113213556.13874.41211.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 1:35 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> Now that the device capabilities are exposed we can add support to
> add and delete flows from the tables.
>
> The two operations are
>
> table_set_flows :
>
>   The set flow operations is used to program a set of flows into a
>   hardware device table. The message is consumed via netlink encoded

should now netlink cmd be called table_set_rules ?
and s/flow/rule/ everywhere in commit log?

>   message which is then decoded into a null terminated  array of
>   flow entry structures. A flow entry structure is defined as
>
>      struct net_flow_flow {

commit log no longer matches implementation ;)
should be net_flow_rule ?

can you update your .html writeup?
I hope to see more real examples in there.

btw how the whole thing will work with queue splitting from
your other patch?
