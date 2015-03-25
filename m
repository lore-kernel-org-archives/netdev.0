From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2] iproute2: unify naming for entries offloaded to
 hardware
Date: Wed, 25 Mar 2015 07:40:48 +0100
Message-ID: <20150325064048.GB2034@nanopsycho.orion>
References: <1427243585-1530-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37316 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbbCYGkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 02:40:51 -0400
Received: by wixw10 with SMTP id w10so24032235wix.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 23:40:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427243585-1530-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 25, 2015 at 01:33:05AM CET, gospo@cumulusnetworks.com wrote:
>The kernel now has the capability to offload FDB and FIB entries to hardware.
>It is important to let users know if table entries are also offloaded to
>hardware.  Currently offloaded FDB entries are indicated by the existence of
>the flag 'external' on the entry as of the following commit:
>
>commit 28467b7f3facd6114b2fbe0c9fecf57adbd52e12
>Author: Scott Feldman <sfeldma@gmail.com>
>Date:   Thu Dec 4 09:57:15 2014 +0100
>
>    bridge/fdb: add flag/indication for FDB entry synced from offload device
>
>When the patch to add support for indicating that FIB entries were also
>offloaded as posted to netdev by Scott Feldman it became clear that 'external'
>would not be an ideal name for routes.  There could definitely be confusion
>about what this might mean since many routes are to external networks -- a
>collision/confusion that did not happen with FDB.
>
>Scott Feldman asked me to check with others and build concensus around a name.
>After speaking with several people about this I am proposing we refer to both
>FDB and FIB entries that are currently backed by hardware (based on the work
>done in rocker) with the flag 'offload' appended to the end ofthe entry.
>
>Some people liked the string 'external,' others liked 'hardware,' but the point
>is to communicate that these routes are available to something that will will
>offload the forwarding normally done by the kernel.  Since the term 'offload'
>is used so frequently it seems appropriate to use the same language in
>ip/bridge output.
>
>The term 'offload' also seems to resonate with many of the people who have
>responded on Scott's original thread or to those who I reached out to directly
>and did respond to my query, so it seems we have reached consensus that it
>should be the term used going forward.
>
>Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

hmm...okay...

Acked-by: Jiri Pirko <jiri@resnulli.us>
