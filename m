From: "Julian C. Dunn" <jdunn@aquezada.com>
Subject: typo in ping.c?
Date: Wed, 5 Jan 2011 22:36:27 -0500
Message-ID: <00c001cbad52$e62ea050$b28be0f0$@aquezada.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport2-out.teksavvy.com ([206.248.154.181]:6075 "EHLO
	ironport2-out.pppoe.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754717Ab1AFDgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 22:36:39 -0500
References: 
In-Reply-To: 
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I sent this about a month ago to Yoshifuji Hideaki but didn't hear anything.
Perhaps it could use a wider distribution.

- Julian

-----Original Message-----
From: Julian C. Dunn [mailto:jdunn@aquezada.com] 
Sent: Sunday, December 12, 2010 8:49 PM
To: 'YOSHIFUJI Hideaki'
Subject: typo in ping.c?

Hi,

I'm not an expert in C code or in iputils but I think I found a
typographical error in this commit:

http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/iputils.git;a=commitdi
ff;h=d5e3dcb81ff3828fa40eb4e8c562ca7015d7ac6a

The previous version printed the icmp_seq inline within ping_common.c, but
in your diff you are now invoking a function void pr_echo_reply().
Unfortunately, it looks like "icmp_seq" is spelled wrong: you have it
spelled as "icmp_req".

I discovered this when trying to use a tool that depended on the spelling of
"icmp_seq" and it failed.

- Julian

