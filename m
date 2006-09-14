From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] genetlink custom attribute type
Date: Thu, 14 Sep 2006 11:21:44 +0200
Message-ID: <1158225704.2936.27.camel@ux156>
References: <1158219852.2936.12.camel@ux156>
	 <20060914081409.GB18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:11698 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751498AbWINJVF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 05:21:05 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060914081409.GB18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-14 at 10:14 +0200, Thomas Graf wrote:

> Looks good, we have to watch the size of struct nla_policy though.
> This bumps the size from 4 bytes to 16 bytes on 64bit architectures
> which might become a problem since we always use ATTR_MAX sized
> arrays.

Yes, I'm aware of that, but I couldn't think of a way to handle it well.

I thought about using a second array containing just the check
functions, and then (ab)using `len' to index into it but that didn't
seem clean enough.

Can you think of something better?

johannes
