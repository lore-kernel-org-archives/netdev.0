From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.21 3/4] cxgb3 - Fix potential MAC hang
Date: Wed, 21 Mar 2007 15:07:48 -0700
Message-ID: <20070321150748.2abf2bd5.akpm@linux-foundation.org>
References: <20070318201011.16310.77866.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:55666 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247AbXCUWIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 18:08:32 -0400
In-Reply-To: <20070318201011.16310.77866.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Mar 2007 13:10:12 -0700
divy@chelsio.com wrote:

> From: Divy Le Ray <divy@chelsio.com>
> 
> Under rare conditions, the MAC might hang while generating a pause frame.
> This patch fine tunes the MAC settings to avoid the issue, allows for 
> periodic MAC state check, and triggers a recovery if hung. 
> 
> Also fix one MAC statistics counter for the rev board T3B2.

This conflicts with your previously-submitted, not-yet-merged-by-Jeff
cxgb3-add-sw-lro-support.patch.

What should we do about this?
