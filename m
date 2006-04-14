From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Fri, 14 Apr 2006 08:27:15 -0700
Message-ID: <20060414152715.GC29461@instant802.com>
References: <443EF3E9.7050303@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffl@comix.santa-cruz.ca.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-10.dex002.intermedia.net ([64.78.21.75]:32884 "EHLO
	dhost002-10.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964992AbWDNP1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 11:27:23 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <443EF3E9.7050303@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 07:59:21PM -0500, Larry Finger wrote:

> I am planning on writing a new routine to be added to 
> net/ieee80211/ieee80211_geo.c that will populate an ieee80211_geo object 
> given a country code. The new routine will eliminate the need for each 
> driver to do their own.

> Neglecting any discussion of maximum power, I have been able to arrange the 
> countries into the following groups:

The maximum power would be quite useful--I would say required--part of
regulatory domain information.. In other words, I would like to see the
groups created in a way that would take differences in power limits into
account. Without this, the groups will need to be re-created at some
point in the future when IEEE 802.11d and IEEE 802.11h would like to use
the same table.. In addition, flag of specifying indoor/outdoor/both
would be a nice addition.

It would be useful to have a text file with all the information in an
easily parseable format. I would like to be able to add a user space
tool that uses this file to take care of channel/TX power policies. The
needed parameters would then be configured for the kernel side 802.11
whenever needed.

-- 
Jouni Malinen                                            PGP id EFC895FA
