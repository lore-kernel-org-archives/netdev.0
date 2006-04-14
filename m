From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Fri, 14 Apr 2006 13:41:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0604141339580.6730@p15091797.pureserver.info>
References: <443EF3E9.7050303@lwfinger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, jeffl@comix.santa-cruz.ca.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:49851 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S932253AbWDNLn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 07:43:59 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <443EF3E9.7050303@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry,

the CISCO list is not correct. For Europe the detailed information
can be found in the recommendation ERC/REC 70-03 of the European
Radiocommunications Office. It is downloadable from this page:

http://www.ero.dk/documentation/docs/doccategory.asp?catid=2&catname=ECC/ERC/ECTRA%20Recommendations

The WLAN frequencies are specified in Annex 3 and the national
restrictions can be found in Appendix 3.

So for 802.11b/g channels 1-13 can be used across Europe. France
has some differing power requirements. Italy require license for
outdoor usage. Luxembourg authorisation for public usage. Romania
requires an individual license.

For the 802.11a frequencies, there are three bands: 

Annex 3 Band B 5150-5250 MHz for indoor use (36-48)
Annex 3 Band C 5250-5350 MHz for indoor use (52-64)
Annex 3 Band D 5470-5725 MHz for outdoor use (100-140)

However these bands are not available in all European states,
details can be found in the recommendation. Spain, Portugal,
Greece and Belgium for instance don't allow Annex 3 Band D.

Uli

On Thu, 13 Apr 2006, Larry Finger wrote:

> I am planning on writing a new routine to be added to
> net/ieee80211/ieee80211_geo.c that will populate an ieee80211_geo object given
> a country code. The new routine will eliminate the need for each driver to do
> their own.
> 
> Finding the allowable channels, etc. for various countries has not been easy;
> however, Cisco
> (http://www.cisco.com/en/US/products/ps6305/products_configuration_guide_chapter
> 09186a008059c96f.html) has what seems to be the most complete listing of
> country information. Neglecting any discussion of maximum power, I have been
> able to arrange the countries into the following groups:

-- 
Ulrich Kunitz - kune@deine-taler.de
