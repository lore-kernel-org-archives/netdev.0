From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Tue, 3 Mar 2015 20:52:49 +0200
Message-ID: <20150303185249.GA2227@angus-think.lan>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
 <20150303095845.5aa844a0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37801 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218AbbCCTEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 14:04:16 -0500
Received: by wibhm9 with SMTP id hm9so2039986wib.2
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 11:04:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150303095845.5aa844a0@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2015 at 09:58:45AM -0800, Stephen Hemminger wrote:
> On Tue,  3 Mar 2015 18:41:18 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > It is possible to use class names from file /etc/iproute2/cls_names
> > which tc will use when showing class info:
> > 
> >     # tc/tc -nm class show dev lo
> > 	class htb 1:10 parent 1:1 leaf 10: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> > 	class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > 	class htb web#1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > 	class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > 	class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > 	class htb voip#1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> > 	class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > 	class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > 
> > or to specify via file path:
> > 
> >     # tc/tc -nm -cf /tmp/cls_names class show dev lo
> > 
> > Class names file contains simple "maj:min  name" structure:
> > 
> > 1:20    web
> > 1:40    voip
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> This adds new dependency on berkely db.
> See how iproute handled that for arpd and use same #ifdef and config.

Sorry I did not get how this adds the dependency for berkely db ?
Would you please help me to understand the problem ?

Thanks,
