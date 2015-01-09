From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Fri, 9 Jan 2015 09:43:15 +0100
Message-ID: <20150109094315.0c370971@griffin>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
	<1420628662-9930-4-git-send-email-vadim4j@gmail.com>
	<54AD5458.6000400@hp.com>
	<20150107173640.GA19586@angus-think.lan>
	<20150107181112.GA24241@angus-think.lan>
	<54AD8BC3.2070609@hp.com>
	<20150107195517.GA4645@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753805AbbAIInV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 03:43:21 -0500
In-Reply-To: <20150107195517.GA4645@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Jan 2015 21:55:17 +0200, Vadim Kochan wrote:
> On Wed, Jan 07, 2015 at 02:40:51PM -0500, Brian Haley wrote:
> > Or you just trap the name "all" in the add case and don't allow it.
> 
> So I think that do not allow to add netns "all" can be a solution, I'd
> like to hear from other people if it might be OK.

You can still add the name manually (there is software out there that
adds symlinks to /ver/run/netns), so nope, that's not a solution.

Generally, the only special names that could be used would be those
containing a letter not allowed in file name, i.e. \0 or '/'. Neither
of those sounds thrilling. I'm afraid the only working solution is a
new option.

 Jiri

-- 
Jiri Benc
