From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: How to hairpin two Ethernet interfaces together (L2 hub/repeater mode)?
Date: Sat, 23 Feb 2013 02:42:50 +0100
Message-ID: <20130223014250.GB6766@order.stressinduktion.org>
References: <CAKuTDr_eC4Wrv=uGthGJk3Zps=fnyAxpqqmsSDau7ZLs4PGyZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Petri Gynther <petri.gynther@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51797 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758756Ab3BWBmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:42:51 -0500
Content-Disposition: inline
In-Reply-To: <CAKuTDr_eC4Wrv=uGthGJk3Zps=fnyAxpqqmsSDau7ZLs4PGyZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2013 at 04:10:54PM -0800, Petri Gynther wrote:
> Any trivial solutions to this? Can Linux bridge be configured in L2
> hub/repeater mode so that it simply floods every Rx frame to all other
> ports of the bridge?

You could have a look at openvswitch, it supports (R)SPAN ports.
