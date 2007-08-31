From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 07/12] sky2: use net_device internal stats
Date: Fri, 31 Aug 2007 06:59:12 -0700
Message-ID: <20070831065912.319c071f@oldman>
References: <20070829193922.078561651@linux-foundation.org>
	<20070829195843.025028477@linux-foundation.org>
	<46D81B09.6080107@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58300 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965077AbXHaN7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 09:59:31 -0400
In-Reply-To: <46D81B09.6080107@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Aug 2007 09:43:37 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> NAK -- grep around net/core, you want ->get_stats()
> 
> 
> 

Unneeded if device leaves get_stats as NULL, then register_netdevice
sets it to internal get stats (in net-2.6.24)
