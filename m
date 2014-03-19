From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next v2 02/15] i40evf: correctly program RSS HLUT table
Date: Wed, 19 Mar 2014 10:08:10 +0200
Message-ID: <CAJZOPZ+RWb-ybx3xmgSpOWRC5a=4-Kp7c4tFu145gtvnTQY8Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:46762 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbaCSIIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 04:08:10 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so8534956pbb.31
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 01:08:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 5:42 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>
> The HLUT programming loop in in i40evf_configure_rss was a) overly-
> complicated, and b) just plain broken. Most of the entries ended up being
> not written at all, so most of the flows ended up at queue zero.

In the V2 cover letter you wrote

dropped patch Mitch's patch "i40evf: correctly program RSS HLUT table"

so what is this patch?
