From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH iproute2] iproute2: unify naming for entries offloaded to hardware
Date: Tue, 24 Mar 2015 18:48:04 -0700
Message-ID: <CAE4R7bDt18VoRvGV0YNRhNPXc_2ZNQFyisBGEwpiq9ZisSyqqA@mail.gmail.com>
References: <1427243585-1530-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"John W. Linville" <linville@tuxdriver.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35965 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbbCYBsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:48:05 -0400
Received: by qgf60 with SMTP id 60so7877414qgf.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 18:48:04 -0700 (PDT)
In-Reply-To: <1427243585-1530-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 5:33 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> The kernel now has the capability to offload FDB and FIB entries to hardware.
> It is important to let users know if table entries are also offloaded to
> hardware.  Currently offloaded FDB entries are indicated by the existence of
> the flag 'external' on the entry as of the following commit:
>
> commit 28467b7f3facd6114b2fbe0c9fecf57adbd52e12
> Author: Scott Feldman <sfeldma@gmail.com>
> Date:   Thu Dec 4 09:57:15 2014 +0100
>
>     bridge/fdb: add flag/indication for FDB entry synced from offload device
>
> When the patch to add support for indicating that FIB entries were also
> offloaded as posted to netdev by Scott Feldman it became clear that 'external'
> would not be an ideal name for routes.  There could definitely be confusion
> about what this might mean since many routes are to external networks -- a
> collision/confusion that did not happen with FDB.
>
> Scott Feldman asked me to check with others and build concensus around a name.
> After speaking with several people about this I am proposing we refer to both
> FDB and FIB entries that are currently backed by hardware (based on the work
> done in rocker) with the flag 'offload' appended to the end ofthe entry.
>
> Some people liked the string 'external,' others liked 'hardware,' but the point
> is to communicate that these routes are available to something that will will
> offload the forwarding normally done by the kernel.  Since the term 'offload'
> is used so frequently it seems appropriate to use the same language in
> ip/bridge output.
>
> The term 'offload' also seems to resonate with many of the people who have
> responded on Scott's original thread or to those who I reached out to directly
> and did respond to my query, so it seems we have reached consensus that it
> should be the term used going forward.
>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: John W. Linville <linville@tuxdriver.com>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Scott Feldman <sfeldma@gmail.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>

Acked-by: Scott Feldman <sfeldma@gmail.com>

Thanks Andy.
