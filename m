From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 16:52:58 +0200
Message-ID: <200610051652.59000.IvDoorn@gmail.com>
References: <4523DA7D.2080604@web.de> <4523E69C.1090408@web.de> <20061005132917.78c985c1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:20066 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751481AbWJEPBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 11:01:25 -0400
Received: by ug-out-1314.google.com with SMTP id o38so200069ugd
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2006 08:01:24 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061005132917.78c985c1@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 October 2006 13:29, Jiri Benc wrote:
> On Wed, 04 Oct 2006 18:51:40 +0200, Jan Kiszka wrote:
> > Ok, I'm not promising success and I'm going to duck immediately if
> > someone else feels like working on it, but I could try to patch in this
> > direction.
> 
> Your patches are welcomed!
> 
> > Now there just remains my precautious question if there are other
> > services in the ieee_80211_hw interface that may conflict with sleeping
> > USB drivers. What about specifying the possible contexts in
> > include/net/d80211.h?
> 
> Yes, that makes sense. Feel free to send a patch :-)

The patch is currently in testing in the rt2x00 tree.
So it will be shortly send to the netdev list. :)

Ivo
