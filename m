From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH next-next 2/7] gre: Move utility functions to common
 headers
Date: Tue, 3 May 2016 13:29:44 +0200
Message-ID: <20160503132944.1951cefb@griffin>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
	<1461975141-954269-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774AbcECL3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 07:29:48 -0400
In-Reply-To: <1461975141-954269-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Apr 2016 17:12:16 -0700, Tom Herbert wrote:
>   - iptunnel_pull_header is taken out of gre_parse_header. This is now
>     done by caller. The header length is returned from gre_parse_header
>     in an int* argument.

Seems we conflicted here, I've done the same for net.git to fix ICMP
path. I made parse_gre_header return the length instead of adding the
parameter, as it's easier consumed that way (no need for an extra local
variable in gre_err).

How do we resolve the conflict between net and net-next? I'd prefer
gre_parse_header to return the header length. I can submit a patch for
net-next that does this; that would substantially ease the merge.

 Jiri
