From: "Merav Sicron" <meravs@broadcom.com>
Subject: RE: [net-next patch] bnx2x: Define bnx2x_tests_str_arr as const
Date: Wed, 27 Jun 2012 15:45:10 +0300
Message-ID: <1340801110.27284.1.camel@lb-tlvb-meravs.il.broadcom.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F68@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3808 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756850Ab2F0MqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 08:46:12 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F68@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 12:59 +0100, David Laight wrote:
> > -static char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
> > +static const char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
> >  	"register_test (offline)    ",
> >  	"memory_test (offline)      ",
> >  	"int_loopback_test (offline)",
> 
> You are still missing a 'const'.
> You probably want:
>   static const char *const bnx2x_tests_str_arr[] ...
> 
> However if you are going to pad the strings to [28]
> you might as well remove the layer of indirection - ie:
>   static const char bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF][28] = { ...
> }
> Or pad to 32 chars to (probably) remove some code bytes.
> 
> 	David
> 
Thanks David, let me think about it.
Dave, please ignore this patch for now.
Thanks,
Merav
