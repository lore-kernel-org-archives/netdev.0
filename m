From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/2] devlink: write usage help messages to
 stderr
Date: Sat, 23 Jul 2016 09:46:59 -0700
Message-ID: <20160723094659.06921b95@xeon-e3>
References: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36832 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbcGWQqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 12:46:45 -0400
Received: by mail-pf0-f182.google.com with SMTP id h186so50595920pfg.3
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 09:46:45 -0700 (PDT)
In-Reply-To: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Jul 2016 18:34:29 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> In order to not confuse reader, write help messages into stderr.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

This does make devlink consistent with other parts of iproute2.
But the most common coding standards, back to Unix, and GNU are
that help messages should go to stdout so that:
  $ ip -h | more
would work as expected.


 http://unix.stackexchange.com/questions/8813/should-the-usage-message-go-to-stderr-or-stdout/8815
 https://www.gnu.org/prep/standards/html_node/_002d_002dhelp.html 
