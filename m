From: David Miller <davem@davemloft.net>
Subject: Re: why is IP_MAX_MTU limited to 65520 bytes
Date: Tue, 25 Aug 2009 16:30:03 -0700 (PDT)
Message-ID: <20090825.163003.153087693.davem@davemloft.net>
References: <1251242740.3169.69.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53958
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932389AbZHYX3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 19:29:51 -0400
In-Reply-To: <1251242740.3169.69.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 25 Aug 2009 16:25:40 -0700

> Any reason why the maximum IP payload is limited to IP_MAX_MTU(0xFFF0) bytes
> instead of the maximum possible value of 0xFFFF

0xffff is an odd value, IP fragments must be a multiple of
8 bytes, etc. etc.
