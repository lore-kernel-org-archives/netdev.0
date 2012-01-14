From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Sat, 14 Jan 2012 12:20:15 -0600
Message-ID: <4F11C75F.9030105@lwfinger.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com> <20120114175837.GA8504@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Tom Gundersen <teg@jklm.no>,
	Andy Whitcroft <apw@canonical.com>,
	Arend van Spriel <arend@broadcom.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43764 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778Ab2ANSUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 13:20:19 -0500
In-Reply-To: <20120114175837.GA8504@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2012 11:58 AM, John W. Linville wrote:
> Kay, thanks for the reports.  Drivers should definitely be loading
> firmware at IFF_UP time.

As the maintainer for several drivers with this problem, I need to make some 
changes. What call from mac80211 corresponds to IFF_UP?

I have looked into using asynchronous firmware loading, but I have not yet found 
a good implementation.

Larry
