From: Julian Anastasov <ja@ssi.bg>
Subject: Re: loopback IP alias breaks tftp?
Date: Thu, 6 Oct 2011 00:18:44 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
References: <20111005202723.GE2479@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:60307 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795Ab1JEVRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 17:17:53 -0400
In-Reply-To: <20111005202723.GE2479@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 5 Oct 2011, Josh Boyer wrote:

> Hi All,
> 
> We've had a report [1] of a change in behavior when trying to use an IP
> alias to tftp from a loopback device.  Apparently the steps outlined in
> the bug worked in 2.6.35, and broke somewhere before 2.6.38.6.
> 
> I can confirm the steps fail on a 3.0 based kernel and I'm trying to do
> a git bisect to find the commit involved, but I thought I would send
> this along to see if anyone might have an idea.  (Also, I'm not really
> sure how valid of a usecase this was to begin with.)

	What about commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c ?

ipv4/route.c: respect prefsrc for local routes

http://marc.info/?t=129412232500001&r=1&w=2

> [1] https://bugzilla.redhat.com/show_bug.cgi?id=739534
> 
> josh

Regards

--
Julian Anastasov <ja@ssi.bg>
