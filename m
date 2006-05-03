From: "David S. Miller" <davem@davemloft.net>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Tue, 02 May 2006 23:47:54 -0700 (PDT)
Message-ID: <20060502.234754.112157906.davem@davemloft.net>
References: <4457E2FE.50505@neterion.com>
	<20060502160058.7af02254@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37284
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965117AbWECGsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 02:48:14 -0400
To: shemminger@osdl.org
In-Reply-To: <20060502160058.7af02254@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I don't think we should be defining driver APIs when we haven't even
figured out how the core of it would even work yet.

A key part of this is the netfilter bits, that will require
non-trivial flow identification, a hash will simply not be enough, and
it will not be allowed to not support the netfilter bits properly
since everyone will have netfilter enabled in one way or another.
