From: Dan Williams <dcbw@redhat.com>
Subject: Re: d80211: RFC: divide by zero when hw->maxssi not set
Date: Sun, 19 Nov 2006 18:55:23 -0500
Message-ID: <1163980523.2881.33.camel@localhost.localdomain>
References: <20061117235109.GA11885@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54991 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933789AbWKSXxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 18:53:44 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061117235109.GA11885@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-17 at 15:51 -0800, David Kimdon wrote:
> Hi,
> 
> commit 448bf25bc9e3d70a211fdf235426472089371c43 added
> ieee80211_get_wireless_stats in net/d80211/ieee80211_ioctl.c.  At
> present we get a divide by zero (oops) if the low level driver does
> not set the new hw->maxssi field.  Perhaps:
> 
> - reject registration of devices which do not set maxssi
> - do not attempt to report link quality for drivers which do not 
>   set maxssi
> - other ideas? 

#1 could be too draconian, but has the benefit of making driver writers
put _something_ there.  Either way, it's pretty obvious to anyone that
the driver is broken for quality reporting.  But at least #1 forces the
issue to making quality somewhat work.

Dan

> -David
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

