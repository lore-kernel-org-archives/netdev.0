From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH 3/6] i40e: Sync link state between VFs and VFPRs
Date: Fri, 30 Dec 2016 09:10:27 -0800
Message-ID: <58669503.2070502@intel.com>
References: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com> <1483078863-22026-4-git-send-email-sridhar.samudrala@intel.com> <CAJ3xEMiQaVc=aJMFJdWEDHEeYL5NnxAcqbM_cTa+X5CkNrLtZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        jakub.kicinski@netronome.com, intel-wired-lan@lists.osuosl.org,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:63723 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750776AbcL3RKa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Dec 2016 12:10:30 -0500
In-Reply-To: <CAJ3xEMiQaVc=aJMFJdWEDHEeYL5NnxAcqbM_cTa+X5CkNrLtZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2016 7:43 AM, Or Gerlitz wrote:
> On Fri, Dec 30, 2016 at 8:21 AM, Sridhar Samudrala
> <sridhar.samudrala@intel.com> wrote:
>
> [..]
>> - enable/disable VF link state via ndo_set_vf_link_state will update the
>>    admin state of associated VFPR.
> why you want to do that? anything missing here w.o using the legacy mode?
Nothing missing.  legacy way of controlling the VF link state is 
supported even in switchdev mode
until it is deprecated.
