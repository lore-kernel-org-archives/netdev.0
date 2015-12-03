From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 07/15] i40e: propagate properly
Date: Thu, 3 Dec 2015 16:00:28 +0200
Message-ID: <CAJ3xEMjX0_TULVQX9XoFvwfH=Lh9_jjc1m_oeu1GXdJBh-QbDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35090 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbbLCOA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 09:00:29 -0500
Received: by igl9 with SMTP id 9so11262660igl.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 06:00:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 3:25 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>

Hi Mitch,

Can you use a more descriptive title for the patch, propagate what properly?


> i40e_sync_vsi_filters() is the surly teenager of this driver. It says
> it's going to report errors, but it doesn't actually do that most of the
> time. And when it does, it leaves a mess.
>
> Change this function to have a common exit point so it will properly
> release the busy lock on the VSI. Propagate errors to the callers.
> Finally, adjust a few callers to check for and deal with errors from
> this function.
