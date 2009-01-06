From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: can't apply sch_multiq
Date: Tue, 6 Jan 2009 08:50:15 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F24A2DE19@orsmsx501.amr.corp.intel.com>
References: <4963392A.2000709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4151 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbZAFQub convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 11:50:31 -0500
In-Reply-To: <4963392A.2000709@bigtelecom.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badalian Vyacheslav wrote:
> Hello all.
> kernel 2.6.28, iproute2 - 2.6.26 (last release)
>
> Look to Documentation/networking/multiqueue.txt we see:
> ---
> The userspace command 'tc,' part of the iproute2 package, is used to
> configure
> qdiscs.  To add the MULTIQ qdisc to your network device, assuming the
> device is called eth0, run the following command:
>
> # tc qdisc add dev eth0 root handle 1: multiq
> ---
>
> Let's try!
> # tc qdisc add dev eth0 root handle 1: multiq
> RTNETLINK answers: Invalid argument
>
> Where mistake?
>
> Thanks for answers!

The only part that is probably missing is that I don't believe the sch_multiq patch been accepted into the iproute2.  Once that is in then tc should work with the multiq qdisc without any issues.

Thanks,

Alex

