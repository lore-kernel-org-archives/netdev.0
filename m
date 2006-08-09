From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: 3945 driver using d80211
Date: Wed, 9 Aug 2006 08:49:58 -0700
Message-ID: <20060809154958.GA26616@instant802.com>
References: <44D901C9.6090304@linux.intel.com> <20060809000631.GH25393@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-82.dex002.intermedia.net ([64.78.20.215]:62421 "EHLO
	dhost002-82.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751068AbWHIPuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 11:50:09 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <20060809000631.GH25393@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 05:06:31PM -0700, Jouni Malinen wrote:
> On Tue, Aug 08, 2006 at 02:27:37PM -0700, Mohamed Abbas wrote:
> 
> > 1- I needed to use sta_info_get function to do rate scaling for 3945, 
> > although this function is exported but it was missing from d80211.h, for 
> > work around I had to copy more header files to my driver's directory, It 
> > this plan to add this function to d80211.h ?
> 
> sta_info_get() (and well, any access to struct sta_info) was not
> designed to be available for the rate control modules. Could you please
> provide some more details on what kind of information you would need
> from there?

Actually, that was not correct.. What I should have said is that
sta_info was not supposed to be available for low-level drivers. If the
rate control algorithm is tightly coupled with the driver, some cleanup
would likely be needed here.

-- 
Jouni Malinen                                            PGP id EFC895FA
