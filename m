From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Forgot "[PATCH]" - Re: Use correct NET_RX_* returns for atalk_rcv()
Date: Fri, 7 Aug 2009 20:04:34 +0930
Message-ID: <20090807200434.818e8159.lk-netdev@lk-netdev.nosense.org>
References: <20090807185122.30f022de.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:55882 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757417AbZHGKeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 06:34:36 -0400
In-Reply-To: <20090807185122.30f022de.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009 18:51:22 +0930
Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:

> 
>     In all rx'd SKB cases, atalk_rcv() either eventually jumps to or falls through
>     to the label out:, which  returns numeric 0. Numeric 0 corresponds to
>     NET_RX_SUCCESS, which is incorrect in failed SKB cases.

<snip>
