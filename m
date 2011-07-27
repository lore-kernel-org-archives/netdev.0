From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] bonding: reduce noise during init
Date: Tue, 26 Jul 2011 17:40:27 -0700
Message-ID: <1311727227.15386.40.camel@Joe-Laptop>
References: <1311716107-12328-1-git-send-email-andy@greyhouse.net>
	 <1311717286.15386.34.camel@Joe-Laptop>  <11239.1311727039@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4323 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970Ab1G0Aka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 20:40:30 -0400
In-Reply-To: <11239.1311727039@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-26 at 17:37 -0700, Jay Vosburgh wrote:
> Joe Perches <joe@perches.com> wrote:
> >I'd prefer you don't separate the format string
> >into multiple pieces.
> Why not?  To me, it looks easier to read split into sections
> that don't wrap lines.

Harder to grep for a dmesg and the
defect rate of these split formats is
typically higher than single strings
because of bad spacing between string
segments.

