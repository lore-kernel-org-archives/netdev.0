From: "Jan Kiszka" <jan.kiszka@googlemail.com>
Subject: Re: [PATCH 4/6] d80211: don't display name of invisible network device
Date: Tue, 30 Jan 2007 15:00:12 +0100
Message-ID: <58d0dbf10701300600h24cdb9b8xabbc27b16d4ddb05@mail.gmail.com>
References: <20070129174809.6401B48499@silver.suse.cz>
	 <1170164845.30318.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:26781 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965364AbXA3OAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 09:00:14 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1536737uga
        for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 06:00:13 -0800 (PST)
In-Reply-To: <1170164845.30318.19.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/1/30, Johannes Berg <johannes@sipsolutions.net>:
> On Mon, 2007-01-29 at 18:48 +0100, Jiri Benc wrote:
> > Invisible master interface does not have meaningful name. Display the wiphy
> > identifier in kernel messages instead.
> >
> > Also, remove the allocation of master interface name as it is purposeless
> > now.
>
> If the master netdev no longer has a name, how can you still use `tc' on
> it?

I hope you can't, because that was recently proven to be able to
subtly break the stack:

http://www.mail-archive.com/netdev@vger.kernel.org/msg29219.html

Jan
