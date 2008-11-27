From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [NET-NEXT PATCH 1/5] igb: link up/down messages must follow a specific format
Date: Thu, 27 Nov 2008 11:50:45 +0100
Message-ID: <87r64x30je.fsf@basil.nowhere.org>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58096 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757261AbYK0Kul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:50:41 -0500
In-Reply-To: <20081127000206.22431.53339.stgit@gitlost.lost> (Jeff Kirsher's message of "Wed, 26 Nov 2008 16:02:06 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> The system log messages created on a link status change need to follow a
> specific format to work with tools some customers use.

It would be better to define standard helper functions that output this
format somewhere. Then this could be also used in other drivers.

-Andi

-- 
ak@linux.intel.com
