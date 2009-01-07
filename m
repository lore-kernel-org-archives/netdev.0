From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Tue, 6 Jan 2009 19:43:12 -0800
Message-ID: <20090106194312.1403ca53@extreme>
References: <200808060042.53503.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33172 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZAGDnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 22:43:20 -0500
In-Reply-To: <200808060042.53503.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Aug 2008 00:42:53 +0300
Denys Fedoryshchenko <denys@visp.net.lb> wrote:

> 1)optind according iptables sources have to be set to 0. If it is set to 1, in 
> batch it will mess up things. Also in iptables sources i notice that ->tflags 
> and ->used need to be reset.
> 
> 2)Since target->t = fw_calloc(1, size); allocated memory in function build_st, 
> it have to be freed at the end, or in batch we will have memory leak. TODO: 
> Probably it must be freed in all "return -1" cases in parse_ipt after 
> build_st. About this i am not sure, up to Stephen.
> 
> 3)lname and new_name was malloc'ed, but not freed

Applied the last patch for this.
