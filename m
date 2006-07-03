From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE]: Introduce tc monitor
Date: Mon, 03 Jul 2006 12:13:53 +0200
Message-ID: <44A8EDE1.7030503@trash.net>
References: <1151860849.5093.259.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63449 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750914AbWGCKPG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 06:15:06 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151860849.5093.259.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Speaking of events reminded me of this.. Managed to get some quality
> time, so heres a patch against current iproute2 git that adds something
> useful.
> 
> This patch adds ability to monitor tc events similar to ipmonitor.
> User runs "tc monitor" (without quotes) and watches events of
> addition, deletion and updates from qdiscs, classes, filters and
> actions as they happen.

Looks good to me. Speaking of actions, do you have any plans to
add help-texts? Currently the output is very confusing, whenever
I use them I need to google for examples.

$ tc action help
action usage improper

$ tc action add mirred help
mirred not supported help
bad action parsing
parse_action: bad value (2:mirred)!
Illegal "action"
Command "add" is unknown, try "tc action help".

