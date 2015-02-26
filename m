From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3] rocker: fix non-portable err return codes
Date: Thu, 26 Feb 2015 12:17:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEE973@AcuExch.aculab.com>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
 <1424924138-15928-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "'sfeldma@gmail.com'" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:63597 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbbBZMSJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 07:18:09 -0500
In-Reply-To: <1424924138-15928-2-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
> The rocker device returns error codes if something goes wrong with descriptor
> processing.  Originally the device used standard errno codes for different
> errors, but since those errno codes aren't portable across ARCHs, the device
> now returns hard-coded error codes that stay constant across diff ARCHs.  Fix
> driver to use those same hard-coded values.

You might as well use dense error numbers and then an array for the conversion.
If you want to avoid confusion, then offset the error numbers from zero.

	David
