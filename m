From: Cong Wang <cwang@twopensource.com>
Subject: Re: What are the intended semantics of IFLA_LINK_NETNSID?
Date: Wed, 25 Feb 2015 21:07:06 -0800
Message-ID: <CAHA+R7N9a+w-L91wyS5nRJOaJJz4B_b-31GhzzyjWyJodVTb3w@mail.gmail.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com>
	<871tldstju.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:43252 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbbBZFHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 00:07:08 -0500
Received: by iebtr6 with SMTP id tr6so11121264ieb.10
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 21:07:06 -0800 (PST)
In-Reply-To: <871tldstju.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 11:03 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> I suspect the correct fix for rtnl_newlink is to just use
> IFLA_LINK_NETNSID in rtnl_link_get_net and have it be an alternative way
> of setting dest_net.  But you may intend some different semantics that
> I don't understand.
>

Looking at the example provided in iproute2, link-netnsid
should refer the the netns, by the given ID, where the underlying
link is. The difference is that this ID is only unique in a given netns,
and refers to another peer netns.
