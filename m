From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: pull request: wireless-2.6 2008-10-29
Date: Wed, 29 Oct 2008 16:23:24 -0700
Message-ID: <20081029162324.28f5864d@infradead.org>
References: <20081029231855.GD3485@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	me@bobcopeland.com
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46702 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871AbYJ2XW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 19:22:58 -0400
In-Reply-To: <20081029231855.GD3485@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 19:18:55 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Dave,
> 
> Another quick round of fixes intended for 2.6.28...
> 
> This includes fixes for bugs 11749 and 11845, fixes a reset-related
> regression in ath5k, fixes a Kconfig-related error for rt2x00, and
> fixes some sparse warnings and a possible buffer overrun in libertas.
> Also, it corrects a spelling error and marks Bob Copeland as an
> ath5k maintainer.

speaking of ath5k:

http://www.kerneloops.org/version.php?start=1835008&end=1867775&version=28-rc

it seems to have added a few WARN_ON()s which now end up at the top of
the list .. are these known or should I spend some time writing reports
for netdev ?
