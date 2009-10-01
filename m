From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] at76c50x-usb: set firmware and hardware version in
 wiphy
Date: Thu, 01 Oct 2009 02:32:27 +0100
Message-ID: <1254360747.23350.2.camel@localhost>
References: <20091001011340.GA3123@tuxdriver.com>
	 <1254359942-3483-1-git-send-email-linville@tuxdriver.com>
	 <1254359942-3483-2-git-send-email-linville@tuxdriver.com>
	 <1254359942-3483-3-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kalle.valo@nokia.com>,
	Kalle Valo <kalle.valo@iki.fi>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20972 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345AbZJABdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 21:33:45 -0400
In-Reply-To: <1254359942-3483-3-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-30 at 21:19 -0400, John W. Linville wrote:
[...]
> +	len = sizeof(wiphy->fw_version);
> +	snprintf(wiphy->fw_version, len, "%d.%d.%d-%d",
> +		 priv->fw_version.major, priv->fw_version.minor,
> +		 priv->fw_version.patch, priv->fw_version.build);
> +	/* null terminate the strings in case they were truncated */
> +	wiphy->fw_version[len - 1] = '\0';
[...]

This last statement is unnecessary; snprintf() always null-terminates
(unless the length is zero).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

