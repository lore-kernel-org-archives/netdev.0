From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: wake up all assocs if sndbuf policy is
 per socket
Date: Tue, 08 Apr 2014 18:23:50 +0200
Message-ID: <53442296.6000908@redhat.com>
References: <1396964037-13245-1-git-send-email-dborkman@redhat.com> <53440A90.2030501@gmail.com> <53440D33.2000809@redhat.com> <53441531.8030009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Neil Horman <nhorman@tuxdriver.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756753AbaDHQYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 12:24:36 -0400
In-Reply-To: <53441531.8030009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2014 05:26 PM, Vlad Yasevich wrote:
...
> This is yet another list traversal with skip_head.  I am going to
> resurrect that code for net-next.

Sounds good! I actually had a look longer time ago, to squeeze
all that logic into a list macro, but so far I didn't find
something clean without appending an if-clause to it that tests
for head element - and that I don't like as it can happen that
unintentionally users could run into a dangling else. In the
end it all looked more complicated than the current code was,
so I wasn't really satisfied and therefore didn't post a
patch. ;)

Cheers,

Daniel
