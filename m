From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Thu, 22 Oct 2009 06:57:25 +0200
Message-ID: <4ADFE635.4020109@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>	<1256115421-12714-9-git-send-email-gilad@codefidence.com>	<4ADED6FA.2030502@gmail.com>	<4ADEE119.7020803@codefidence.com>	<4ADF616B.1090405@gmail.com> <20091022003245.5cd4885c.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37812 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbZJVE51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 00:57:27 -0400
In-Reply-To: <20091022003245.5cd4885c.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink a =E9crit :

> And as mentioned previously, the global options can be quite useful
> in certain test scenarios.  I also agree the per route settings are
> a very useful addition.  I think the global and per route settings
> are complementary and shouldn't be thought of as in conflict with
> one another.
>=20

Absolutely, global setting is a must when an admin wants a quick path.

The more flexible would be to have two bits per route, plus
2 bits on the global configuration.

global conf:
00 : timestamps OFF, unless a route setting is not 00
01 : timestamps ON, unless a route setting is not 00
10 : Force timestamps OFF, ignore route settings (emergency sysadmin re=
quest)
11 : Force timestamps ON, ignore route settings=20

Route settings (used *only* if global setting is 0Y)
00 : global conf is used
01 : Force timestamps being OFF for this route
10 : Force timestamps being ON for this route
11 : complement global conf
