From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Fri, 6 Mar 2015 13:06:47 +0200
Message-ID: <20150306110647.GA17353@angus-think.wlc.globallogic.com>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
 <20150303095845.5aa844a0@urahara>
 <20150303185249.GA2227@angus-think.lan>
 <20150305162716.6145cdf2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35921 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599AbbCFLSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 06:18:32 -0500
Received: by lbiz11 with SMTP id z11so30912655lbi.3
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 03:18:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150305162716.6145cdf2@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2015 at 04:27:16PM -0800, Stephen Hemminger wrote:
> On Tue, 3 Mar 2015 20:52:49 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > Sorry I did not get how this adds the dependency for berkely db ?
> > Would you please help me to understand the problem ?
> > 
> > Thanks,
> 
> Sorry, i was thinking and typing at same time.
> I was thinking this would be a good case for using a berkely db for
> 1000's of classes, but a file works ok.

I think that /etc/iproute2/tc_cls might be better name for the default db file.

Also if this feature have chance to be applied I will try to add ability
to use class name to other places - 'tc filter', 'tc class del/change/show'.
