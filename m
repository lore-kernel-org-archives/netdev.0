From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 14:07:57 -0500
Message-ID: <1241032077.7487.16.camel@Maple>
References: <1240945659.8819.9.camel@Maple>
	 <20090428.221605.71993506.davem@davemloft.net>
	 <1241012897.7487.12.camel@Maple>
	 <1241025057.17018.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:61186 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbZD2TID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 15:08:03 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1000561wfd.4
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 12:08:02 -0700 (PDT)
In-Reply-To: <1241025057.17018.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 10:10 -0700, Don Fry wrote:
> How would this be tested on all architectures to find out?

Testing could never prove that the barriers _aren't_ needed, because
you'd never be sure that you'd hit the right conditions. 

  --  John

