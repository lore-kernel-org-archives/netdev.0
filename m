From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 10:37:52 +0200
Message-ID: <20131007083752.GA20271@sesse.net>
References: <20130927201420.GB12043@sesse.net>
 <20130928203318.GC23654@order.stressinduktion.org>
 <20131006120612.GA27852@sesse.net>
 <20131007015252.GE9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:42048 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577Ab3JGIhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 04:37:54 -0400
Content-Disposition: inline
In-Reply-To: <20131007015252.GE9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 03:52:52AM +0200, Hannes Frederic Sowa wrote:
>> pannekake:~> cat /proc/net/ipv6_route 
>> 2001067c00a400037c4d9ae8ab73230f 80 00000000000000000000000000000000 00 fe80000000000000023048fffe555743 00000000 00000001 00000137 01000023     eth0
> This one does look like the most probable route which could have the problem.
> It has a RTF_MODIFIED flag indicating it received a pmtu update.

I got the idea to correlate auth.log with the email I sent:

Oct  6 14:01:12 pannekake sshd[13211]: Accepted keyboard-interactive/pam for
sesse from 2001:67c:a4:3:7c4d:9ae8:ab73:230f port 60116 ssh2

So that's definitely the right address.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
