From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 12:34:57 -0400
Message-ID: <1180542897.4109.81.camel@localhost>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
	 <1180536987.4109.19.camel@localhost>  <465D97F1.9090600@trash.net>
	 <1180541401.4109.72.camel@localhost>  <465DA4E9.5060906@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:14332 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbXE3QfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:35:00 -0400
Received: by wr-out-0506.google.com with SMTP id 76so911438wra
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 09:34:59 -0700 (PDT)
In-Reply-To: <465DA4E9.5060906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-30-05 at 18:23 +0200, Patrick McHardy wrote:

> I think exposing SFQ's queues as classes is a good thing, it allows
> you to do whatever classification you want. In fact I'm probably
> going to add patch on top to also dump them to userspace. 

Yes, that would be useful.

> What
> remains for SFQ to do is serve the queues evenly.

And it does (yes, I looked at the patch;->).  

> My classifier seperates them entirely. The only thing it keeps
> in SFQ is the old classifier for compatibility, besides that its
> exactly what you say. It should be easily possible to remove it
> entirely and use my classifier in a compatible configuration
> automatically.
> 

If you removed it entirely (and had it as a separate classifier) IMO
that would be a better approach. Then what you have is a pure FQ qdisc.
In which case, you leave alone SFQ and have a new qdisc.
The "removed" hashing dynamic classifier would of course be better off
it allowed the user to select a hash algorithm such as the other ones
specified in ESFQ.

cheers,
jamal

