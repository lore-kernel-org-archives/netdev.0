From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 3945 driver using d80211
Date: Wed, 09 Aug 2006 09:57:12 +0200
Message-ID: <44D99558.1000507@sipsolutions.net>
References: <44D901C9.6090304@linux.intel.com> <200608081440.48623.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohamed Abbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:27270 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030437AbWHIH5c
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:57:32 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608081440.48623.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> I think it would be best if you made the firmware not be aware of a 
> connection, and let the d80211 code take care of all the 
> scanning/authenticating/associating. Of course, I know nothing about 3945, so 
> I don't know if that's possible.
>   
Please not, for now. We need someone pushing for fullmac features in 
d80211, we need those anyway for embedded systems that can't afford 
running all of it on the main CPU. While obviously Intel would benefit 
from doing this since a lot more d80211 features would come available, 
the greater good would be having a main-stream card that someone cares 
about and helps making d80211 full-mac capable.

johannes
