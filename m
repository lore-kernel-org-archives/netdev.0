From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] net: Verify permission to dest_net in newlink
Date: Fri, 27 Feb 2015 10:03:29 +0100
Message-ID: <54F032E1.1000409@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>	<54EEDF9C.20302@6wind.com> <87wq34okb9.fsf@x220.int.ebiederm.org>	<54EF3338.8000409@6wind.com> <87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:43747 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbB0JDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 04:03:33 -0500
Received: by wggy19 with SMTP id y19so18529901wgg.10
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 01:03:31 -0800 (PST)
In-Reply-To: <87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/02/2015 23:19, Eric W. Biederman a =C3=A9crit :
>
> When applicable verify that the caller has permision to create a
> network device in another network namespace.  This check is already
> present when moving a network device between network namespaces in
> setlink so all that is needed is to duplicate that check in newlink.
>
> This change almost backports cleanly, but there are context conflicts
> as the code that follows was added in v4.0-rc1
>
> Fixes: b51642f6d77b131dc85d1d71029c3cbb5b07c262 net: Enable a userns =
root rtnl calls that are safe for unprivilged users
12 digits is enough for the sha1 and commit title should be formatted l=
ike this
("commit title")
See=20
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Doc=
umentation/SubmittingPatches#n187

=46ixes: b51642f6d77b ("net: Enable a userns root rtnl calls that are s=
afe for=20
unprivilged users")
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
