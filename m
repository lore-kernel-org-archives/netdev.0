From: Dave Jones <davej@redhat.com>
Subject: Re: TCP output handling bug ?
Date: Thu, 21 Aug 2014 22:13:41 -0400
Message-ID: <20140822021341.GB14353@redhat.com>
References: <20140821190208.208e0de1@www.etchedpixels.co.uk>
 <20140821172445.7c1ba422@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757AbaHVCN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 22:13:59 -0400
Content-Disposition: inline
In-Reply-To: <20140821172445.7c1ba422@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2014 at 05:24:45PM -0700, Stephen Hemminger wrote:
 > On Thu, 21 Aug 2014 19:02:08 +0100
 > Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
 > 
 > > 
 > > tcp_send_syn_data:
 > > 
 > >         TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
 > >         TCP_SKB_CB(data)->tcp_flags = (TCPHDR_ACK|TCPHDR_PSH);
 > > 
 > > the reporter has a point 8)
 > > 
 > > https://bugzilla.kernel.org/show_bug.cgi?id=82101
 > 
 > I wonder if covertity or smatch could be smart enough to catch this kind of bug?

For coverity: it should be, but isn't :)
I've pointed them at the bugzilla, maybe they can add a check in a
future update.

I bet this isn't the only instance of a bug like this left in the tree.
We've definitely had similar cases before.

	Dave
