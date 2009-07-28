From: Philip Craig <philipc@snapgear.com>
Subject: Re: [question] bridged tunnel
Date: Tue, 28 Jul 2009 18:28:05 +1000
Message-ID: <4A6EB695.2070202@snapgear.com>
References: <20090728075928.GB3633@psychotron.englab.brq.redhat.com> <200907281111.16433.remi.denis-courmont@nokia.com> <20090728081818.GA6522@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:33033 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750733AbZG1I2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:28:05 -0400
In-Reply-To: <20090728081818.GA6522@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Well generally there could be anything (e.g. internet) in between ROUTER A and
> B. That's why.

If the internet is in the middle, then you don't want to invent your own
tunneling.  Using something like OpenVPN in tap mode, or gretap over IPSec.

