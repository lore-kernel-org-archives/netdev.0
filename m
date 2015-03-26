From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Thu, 26 Mar 2015 15:22:47 +0100
Message-ID: <20150326142247.GB2010@nanopsycho.orion>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <20150326132532.GB20404@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	jesse@nicira.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38795 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbbCZOWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:22:50 -0400
Received: by wibgn9 with SMTP id gn9so87654401wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:22:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150326132532.GB20404@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 26, 2015 at 02:25:32PM CET, tgraf@suug.ch wrote:
>On 03/26/15 at 01:53pm, Jiri Pirko wrote:
>> This patch introduces OpenFlow-based filter. So far, the very essential
>> packet fields are supported (according to OpenFlow v1.4 spec).
>> 
>> This patch is only the first step. There is a lot of potential performance
>> improvements possible to implement. Also a lot of features are missing
>> now. They will be addressed in follow-up patches.
>> 
>> To the name of this classifier, I believe that "cls_openflow" is pretty
>> accurate. It is actually a OpenFlow classifier.
>
>My feedback on this was that this could be misleading because
>cls_openflow does not make the kernel an OpenFlow switch (neither
>does OVS). I can see the relation to some of the match fields as
>specified by OpenFlow but there is no relation to the wire protocol
>itself or any of the other OpenFlow specific concepts such as flow
>tables, group tables, counters, actions, etc.
>
>That said, I can see what you mean by it and I think if we make this
>clear in the description and manual page that might be enough to
>avoid confusion.


Okay, I will add some note to file headers. Manpages for tc are in
awful state, not sure where to put it there.
