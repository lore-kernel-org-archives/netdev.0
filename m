From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] connector: add userspace example code into
 Documentation/connector/
Date: Fri, 25 Aug 2006 01:17:27 -0700 (PDT)
Message-ID: <20060825.011727.35466920.davem@davemloft.net>
References: <20060825071102.GD1816@2ka.mipt.ru>
	<20060825.005233.28788815.davem@davemloft.net>
	<20060825081502.GA17120@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21144
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932138AbWHYIR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 04:17:26 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060825081502.GA17120@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 25 Aug 2006 12:15:03 +0400

> I mailed it myself and applied to 2.6.18 git tree - "patch -p1" did
> not complain for sure :)

GIT always complains very loudly about any trailing whitespace on any
lines, patch is too dumb to do that.

You do not need to use GIT trees to check this, just run:

git apply --check --whitespace=error-all $PATCH

and it will let you know.
