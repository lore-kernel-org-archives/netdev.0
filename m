From: Mark Lord <mlord@pobox.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 17:20:40 -0500
Message-ID: <52EAD038.5020409@pobox.com>
References: <22081260.RNay0J72dY@athas> <20140129215408.GC5991@xanatos> <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com> <20140130184412.GA3787@xanatos> <A2CA0424C0A6F04399FB9E1CD98E03046D147453@US01WEMBX2.internal.synopsys.com> <52EAAF6F.7070202@pobox.com> <20140130214133.GB14228@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Paul Zimmerman <paulz@synopsys.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"renevant@internode.on.net" <renevant@internode.on.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:51148 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbaA3WUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 17:20:42 -0500
In-Reply-To: <20140130214133.GB14228@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-30 04:41 PM, Sarah Sharp wrote:
>
> Mark and David, can you pull the 3.13-td-changes-reverted branch again,
> and see if the latest patch fixes your issue?  It disables scatter
> gather for the ax88179_178a device, but only when it's operating at USB
> 3.0 speeds.

As expected, this works just fine.


-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
