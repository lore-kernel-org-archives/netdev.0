From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 32/36] net: wireless: convert class code to use
 dev_groups
Date: Thu, 25 Jul 2013 09:50:56 +0200
Message-ID: <1374738656.8827.1.camel@jlt4.sipsolutions.net>
References: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
	 <1374703539-9705-33-git-send-email-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:53311 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314Ab3GYHvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 03:51:07 -0400
In-Reply-To: <1374703539-9705-33-git-send-email-gregkh@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 15:05 -0700, Greg Kroah-Hartman wrote:
> The dev_attrs field of struct class is going away soon, dev_groups
> should be used instead.  This converts the networking wireless class
> code to use the correct field.
> 
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: John W. Linville <linville@tuxdriver.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> 
> John, feel free to take this through your tree, or ACK it and I can take
> it through mine.

It's cfg80211 so it should be me, but I don't expect any conflicts so
please take it.

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes
