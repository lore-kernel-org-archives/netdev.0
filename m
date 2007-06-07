From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Module for ip utility to support veth device (v.2)
Date: Thu, 7 Jun 2007 08:59:46 -0700
Message-ID: <20070607085946.1c168792@localhost.localdomain>
References: <4667E83E.2060405@openvz.org>
	<4667E912.3020204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56425 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764624AbXFGQAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 12:00:15 -0400
In-Reply-To: <4667E912.3020204@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 07 Jun 2007 15:16:34 +0400
Pavel Emelianov <xemul@openvz.org> wrote:

> The usage is
> # ip link add [name] type veth [peer <name>] [mac <mac>] [peer_mac <mac>]
> 
> This version doesn't include the fix for ip/iplink.c as Patrick
> said that he had included it into his patches already.
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>

If this goes in to the mainline kernel, I'll add it to iproute2.
Don't want to put anything in now because of possible interface changes.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
