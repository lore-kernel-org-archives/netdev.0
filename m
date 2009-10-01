From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: [PATCH 3/3] at76c50x-usb: set firmware and hardware version in wiphy
Date: Thu, 01 Oct 2009 17:27:17 +0300
Message-ID: <877hvfqjei.fsf@purkki.valot.fi>
References: <20091001011340.GA3123@tuxdriver.com>
	<1254359942-3483-1-git-send-email-linville@tuxdriver.com>
	<1254359942-3483-2-git-send-email-linville@tuxdriver.com>
	<1254359942-3483-3-git-send-email-linville@tuxdriver.com>
	<1254360747.23350.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:43128 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932474AbZJAO1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 10:27:17 -0400
In-Reply-To: <1254360747.23350.2.camel@localhost> (Ben Hutchings's message of "Thu\, 01 Oct 2009 02\:32\:27 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Wed, 2009-09-30 at 21:19 -0400, John W. Linville wrote:
> [...]
>> +	len = sizeof(wiphy->fw_version);
>> +	snprintf(wiphy->fw_version, len, "%d.%d.%d-%d",
>> +		 priv->fw_version.major, priv->fw_version.minor,
>> +		 priv->fw_version.patch, priv->fw_version.build);
>> +	/* null terminate the strings in case they were truncated */
>> +	wiphy->fw_version[len - 1] = '\0';
> [...]
>
> This last statement is unnecessary; snprintf() always null-terminates
> (unless the length is zero).

Yes, the extra null termination is unnecessary. This was my mistake in
the first patchset I sent.

-- 
Kalle Valo
