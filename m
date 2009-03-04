From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
	non-drops and modifying end-of-line points for skbs
Date: Wed, 4 Mar 2009 09:18:31 -0500
Message-ID: <20090304141831.GB6139@hmsreliant.think-freely.org>
References: <20090303170307.GD1480@hmsreliant.think-freely.org> <20090304135415.GB6392@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56190 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbZCDOSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 09:18:42 -0500
Content-Disposition: inline
In-Reply-To: <20090304135415.GB6392@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 04, 2009 at 10:54:15AM -0300, Arnaldo Carvalho de Melo wrote:
> Em Tue, Mar 03, 2009 at 12:03:07PM -0500, Neil Horman escreveu:
> > 
> > Network Drop Monitor: Adding kfree_skb_clean for non-drops and modifying end-of-line points for skbs
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Why just not add a "drop_skb()" instead? kfree_skb_clean sounds as if we
> will do some cleanup on the skb being freed. "drop_skb()" seems much
> clearer.
> 
> - Arnaldo
> 

Check the RFC thread.  The cases in which we are dropping far outnumber the set
of cases in which we free the skb simply because its the end of the line.
Theres far less churn this way

Neil

