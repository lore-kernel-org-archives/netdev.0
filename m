From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Fri, 14 Apr 2006 15:01:20 -0500
Message-ID: <443FFF90.7030204@lwfinger.net>
References: <443EF3E9.7050303@lwfinger.net> <20060414152715.GC29461@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:32729 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965094AbWDNUB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 16:01:26 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060414152715.GC29461@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> The maximum power would be quite useful--I would say required--part of
> regulatory domain information.. In other words, I would like to see the
> groups created in a way that would take differences in power limits into
> account. Without this, the groups will need to be re-created at some
> point in the future when IEEE 802.11d and IEEE 802.11h would like to use
> the same table.. In addition, flag of specifying indoor/outdoor/both
> would be a nice addition.
> 
> It would be useful to have a text file with all the information in an
> easily parseable format. I would like to be able to add a user space
> tool that uses this file to take care of channel/TX power policies. The
> needed parameters would then be configured for the kernel side 802.11
> whenever needed.

Good idea to include power and indoor etc. flags. I will also include flags to indicate that 
scanning should be passive on a given channel.

Have you any thoughts on the structure of the text file for parsing?

Larry


