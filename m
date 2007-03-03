From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH 2/3] bonding: only receive ARPs for us
Date: Fri, 02 Mar 2007 17:38:22 -0800
Message-ID: <3729.1172885902@death>
References: <200703010103.l2113R22030799@death.nxdomain.ibm.com> <45E8CEB0.3070204@garzik.org>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:46257 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992885AbXCCBiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 20:38:24 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l231cOug007570
	for <netdev@vger.kernel.org>; Fri, 2 Mar 2007 20:38:24 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l231cOGT194450
	for <netdev@vger.kernel.org>; Fri, 2 Mar 2007 18:38:24 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l231cNYR010865
	for <netdev@vger.kernel.org>; Fri, 2 Mar 2007 18:38:24 -0700
In-reply-to: <45E8CEB0.3070204@garzik.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:

>Jay Vosburgh wrote:
>> 	The ARP validation code only needs ARPs for the bonding device.
>> 
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>
>I seem to have lost the context of this.  Did this get discussed, and 
>need further revision?

	The further discussion can be (loosely) paraphrased as:

Andy Gospodarek <andy@greyhouse.net>: "Hey, this no workee with IPv6."

Me: "True, but bonding no workee with IPv6 at all."

Andy: "Oh, ok.  Ack."

	After which followed some preliminary yakkage about fixing up
said non-workee IPv6 support.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
