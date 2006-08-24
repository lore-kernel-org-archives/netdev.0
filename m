From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/4] Try 2: Add wireless statistics to d80211
Date: Thu, 24 Aug 2006 13:17:42 -0500
Message-ID: <44EDED46.6090201@lwfinger.net>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B6E8@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, John Linville <linville@tuxdriver.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:10955 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751642AbWHXSRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 14:17:46 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B6E8@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Barber wrote:
> Why have both signal and rssi measures?

In the bcm43xx driver, the values are different. There is a routine that converts from rssi as a 
positive number into signal in a negative number that looks like dBm. Because of the reverse 
engineering, we have no idea what the logic behind this is, but I thought that we should keep it.

Larry

