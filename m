From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] e1000: disable TSO workaround on 82544
Date: Fri, 27 Jun 2008 01:13:27 -0400
Message-ID: <486476F7.9010506@garzik.org>
References: <20080619211836.GC22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40718 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085AbYF0FNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:13:30 -0400
In-Reply-To: <20080619211836.GC22981@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> It appears that the 82544 does not need the TSO workaround needed on
> other chips.  This seems to resolve excessive messages that appear to be
> Tx Unit Hangs when a system is under heavy stress.

Do these excessive messages occur for all systems with the TSO 
workaround?  i.e. does this patch merely remove one chip from the list 
of chips that receive excessive messages?


