From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Driver build-testing (was: [PATCH] net: dm9000: Fix build)
Date: Mon, 18 Apr 2011 13:12:03 +0200
Message-ID: <20110418111203.GB18324@rere.qmqm.pl>
References: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:32897 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab1DRLME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 07:12:04 -0400
Content-Disposition: inline
In-Reply-To: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 12:04:37PM +0100, Mark Brown wrote:
> Commit c88fcb (net: dm9000: convert to hw_features) broke the build o=
f
> the dm9000 driver since it merged functions which use different names
> for the board info structure used for I/O operations without updating
> all the references to use the same name. Fix that.

[...]

This brings the issue of build testing effectiveness. In current code
there is no configuration that makes all drivers build. I would like
to see something like 'make brokenconfig' that would allow most of
the code to be built, and not necessarily working. Maybe someone has
an idea how to implement that?

Best Regards,
Micha=B3 Miros=B3aw
