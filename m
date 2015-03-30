From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] netlink: pad nla_memcpy dest buffer with zeroes
Date: Mon, 30 Mar 2015 12:31:30 +0100
Message-ID: <20150330113130.GA28989@casper.infradead.org>
References: <34fc9fcd5e67ad578fc5a1a2eb30cf52ffbba082.1427637780.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60437 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbbC3Lbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 07:31:31 -0400
Content-Disposition: inline
In-Reply-To: <34fc9fcd5e67ad578fc5a1a2eb30cf52ffbba082.1427637780.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/15 at 04:05pm, Jiri Benc wrote:
> This is especially important in cases where the kernel allocs a new
> structure and expects a field to be set from a netlink attribute. If such
> attribute is shorter than expected, the rest of the field is left containing
> previous data. When such field is read back by the user space, kernel memory
> content is leaked.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

I think it is safe to assume that the caller intents to get all
of the destination buffer filled just as memcpy() would do.

Acked-by: Thomas Graf <tgraf@suug.ch>
