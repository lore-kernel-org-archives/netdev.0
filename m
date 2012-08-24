From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink scm creds uid and gids are always 0.
Date: Fri, 24 Aug 2012 09:57:45 +0200
Message-ID: <1345795065.5904.2287.camel@edumazet-glaptop>
References: <871uiwlrf3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42240 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820Ab2HXH5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 03:57:50 -0400
Received: by bkwj10 with SMTP id j10so485573bkw.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 00:57:48 -0700 (PDT)
In-Reply-To: <871uiwlrf3.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 23:45 -0700, Eric W. Biederman wrote:
> While working on the kuid_t and kgid_t conversion of the audit subsystem
> I noticed that since the performance problem of scm creds and af_unix
> sockets were fixed af_netlink sockets have not filled in the uid or gid
> of the originator of the socket.
> 
> I think all we need is an appropriate cred_to_ucred call to fix this
> regression, but I am going so many different directions right now I
> can't get myself to focus on this long enough to work up an appripriate
> patch to fix.
> 
> Eric do you think you might take a gander?

Wasnt it fixed by e0e3cea46d31d23dc40df0a49a7a2c04fe8edfea

af_netlink: force credentials passing [CVE-2012-3520]

Or is it a different thing ?
