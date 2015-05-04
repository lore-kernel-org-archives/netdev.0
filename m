From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Sun, 03 May 2015 21:39:12 -0700
Message-ID: <5546F7F0.6010404@cumulusnetworks.com>
References: <1430583883-3514-1-git-send-email-roopa@cumulusnetworks.com> <9B0331B6EBBD0E4684FBFAEDA55776F9193A4364@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34014 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbEDEjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:39:15 -0400
Received: by pacyx8 with SMTP id yx8so150623693pac.1
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 21:39:14 -0700 (PDT)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F9193A4364@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/15, 2:28 AM, Rosen, Rami wrote:
> Hi,
> Removing the netdev_switch_fib_ipv4_abort() when there is an error in programming fib entry in hardware seems reasonable to me. I Just want to note that this is not only a matter of CPU strength; even if the switches' CPUs were powerful enough to do routing in software, still doing so seems not a good option, as routing is implemented in different ways by different switch vendors.
>
>
agree,

thanks.
