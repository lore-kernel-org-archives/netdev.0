From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Thu, 01 Jul 2010 08:37:01 +0200
Message-ID: <4C2C378D.4090806@redhat.com>
References: <4C2B0614.9040004@redhat.com> <201006300959.37145.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab0GAGhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 02:37:35 -0400
In-Reply-To: <201006300959.37145.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.06.2010 18:59, Casey Leedom wrote:
> | From: Stefan Assmann <sassmann@redhat.com>
> | Date: Wednesday, June 30, 2010 01:53 am
> | 
> | This is not a udev bug since udev doesn't create persistent rules for
> | VFs as their MAC address changes every reboot.
> | 
> | To avoid this problem we could change the kernel name for the VFs and
> | thus avoid confusion between VFs and PFs.
> | 
> | I've already discussed this with Alexander Duyck and Greg Rose, so far
> | they have no objection. However this problem appears for all drivers that
> | support PFs and VFs and thus the changes should be applied consistently
> | to all of these drivers.
> 
>   I'm not sure that this problem affects "all drivers which support PFs and VFs."  
> I think that you might mean "all drivers which support PFs and VFs with non-
> persistent MAC addresses for the VFs."  For instance, the MAC addresses 
> associated with the new cxgb4vf VFs are persistent so, from what I understand of 
> the scenario you outlined, I don't think that they would trigger the problem you 
> describe.  Please correct me if I've missed something.  Thanks.
> 
> Casey

You're correct, the problem shouldn't occur with cxgb4vf and therefore
this change shouldn't be necessary. However we might consider a
consistent naming scheme for VFs in all drivers. But I don't have a
strong opinion about this, either way would be fine by me.

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
