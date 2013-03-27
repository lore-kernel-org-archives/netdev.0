From: Jesse Gross <jesse@nicira.com>
Subject: Re: Is there a preferred way to get the VXLAN port number?
Date: Wed, 27 Mar 2013 10:26:06 -0700
Message-ID: <CAEP_g=9cXwxNE=Fxis2F_qStp1gPsjyXr2wE2agHO9rLZcquXA@mail.gmail.com>
References: <51521B05.6060401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>, pshelar@nicira.com,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:53089 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751457Ab3C0R01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:26:27 -0400
Received: by mail-ob0-f200.google.com with SMTP id un3so43077359obb.7
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 10:26:27 -0700 (PDT)
In-Reply-To: <51521B05.6060401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 3:02 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> I was wondering if someone would happen to know if there is already a
> preferred way to get the VXLAN port number for things such as
> configuring a device to recognize a VXLAN frame on receive for parsing
> purposes?
>
> I just wanted to check to make sure I hadn't missed something before
> submitting a patch that would export a simple function for supplying the
> vxlan_port value.

There isn't a good way to do this at the moment.  One thing that would
be nice though is if we can make this as generic as possible to
different tunneling formats that might need to be configured in this
way rather than specific to VXLAN.

Another area think about is how best to supply the information to
GRO/RPS to do the software version of these offloads.
