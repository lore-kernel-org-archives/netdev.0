From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/5] ip fou: Support to configure foo-over-udp
 RX
Date: Sun, 2 Nov 2014 11:45:39 -0800
Message-ID: <20141102114539.460a15b2@urahara>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
	<1412351718-22921-3-git-send-email-therbert@google.com>
	<20141102113610.785543ff@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38120 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbaKBTpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 14:45:51 -0500
Received: by mail-pd0-f181.google.com with SMTP id y10so10321263pdj.12
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 11:45:50 -0800 (PST)
In-Reply-To: <20141102113610.785543ff@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Nov 2014 11:36:10 -0800
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Fri,  3 Oct 2014 08:55:15 -0700
> Tom Herbert <therbert@google.com> wrote:
> 
> > Added 'ip fou...' commands to enable/disable UDP ports for doing
> > foo-over-udp and Generic UDP Encapsulation variant. Arguments are port
> > number to bind to and IP protocol to map to port (for direct FOU).
> > 
> > Examples:
> > 
> > ip fou add port 7777 gue
> > ip fou add port 8888 ipproto 4
> > 
> > The first command creates a GUE port, the second creates a direct FOU
> > port for IPIP (receive payload is a assumed to be an IPv4 packet).
> > 
> > Signed-off-by: Tom Herbert <therbert@google.com>
> 
> Accepted.
> Also discovered that fou.h was missing from kernel Kbuild uapi.

I backed out the change since the rest of the patch series has
issues. Please fix and resubmit
