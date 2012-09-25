From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe unstable performance at 1Gb/s
Date: Tue, 25 Sep 2012 17:58:38 +0000
Message-ID: <87618083B2453E4A8714035B62D6799216E25153@FMSMSX102.amr.corp.intel.com>
References: <loom.20120924T193212-646@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Charles <charles.vejnar@unige.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19214 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756968Ab2IYR6k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 13:58:40 -0400
In-Reply-To: <loom.20120924T193212-646@post.gmane.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Charles
>Sent: Monday, September 24, 2012 10:47 AM
>To: netdev@vger.kernel.org
>Subject: ixgbe unstable performance at 1Gb/s
>
>Hi,
>
>I hope I am posting on the right mailing-list. If not, sorry; please
>redirect me
>to the right place. Thanks.
>
>I have a new motherboard with integrated Intel X540 10GBase-T. For now, I
>want
>to use it at 1Gb/s.
>
>The bandwidth is only of ~300 Mbit/s (with Iperf). It's actually very
>unstable
>(always varies between 100 to 800 Mbit/s during the transfer).

Do you by any chance have CONFIG_IXGBE_PTP set in your kernel config?

If so, try disabling it and see if it fixes your performance. 

Thanks,
Emil
