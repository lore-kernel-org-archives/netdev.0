From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net] gre: set inner_protocol on xmit
Date: Fri, 12 Aug 2016 17:15:22 +0200
Message-ID: <20160812151521.GA25506@penelope.isobedori.kobe.vergenet.net>
References: <20160812094656.GA26953@penelope.isobedori.kobe.vergenet.net>
 <CAKgT0UcxeMwfH4vVNoMccLOhQ_9FDkHBGu_S=uk7G5yCQ1kv8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36020 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbcHLPP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:15:26 -0400
Received: by mail-wm0-f48.google.com with SMTP id q128so33896871wma.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:15:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKgT0UcxeMwfH4vVNoMccLOhQ_9FDkHBGu_S=uk7G5yCQ1kv8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 08:07:00AM -0700, Alexander Duyck wrote:
> On Fri, Aug 12, 2016 at 2:46 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Ensure that the inner_protocol is set on transmit so that GSO segmentation,
> > which relies on that field, works correctly.
> >
> > I have observed this is not the case when OvS transmits GRE using
> > lwtunnel metadata (which it always does).
> >
> > Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
> > Cc: Alexander Duyck <aduyck@mirantis.com>
> > Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
> > Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> Looks good.  I'm surprised we had such a difference in how this was
> handled between the flow based and device based paths.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

Thanks, I have reposted with the above Ack and no RFC designation.
