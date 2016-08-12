From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH/RFC net] gre: set inner_protocol on xmit
Date: Fri, 12 Aug 2016 08:07:00 -0700
Message-ID: <CAKgT0UcxeMwfH4vVNoMccLOhQ_9FDkHBGu_S=uk7G5yCQ1kv8Q@mail.gmail.com>
References: <20160812094656.GA26953@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33808 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431AbcHLPHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 11:07:01 -0400
Received: by mail-io0-f169.google.com with SMTP id q83so27140062iod.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 08:07:01 -0700 (PDT)
In-Reply-To: <20160812094656.GA26953@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 2:46 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Ensure that the inner_protocol is set on transmit so that GSO segmentation,
> which relies on that field, works correctly.
>
> I have observed this is not the case when OvS transmits GRE using
> lwtunnel metadata (which it always does).
>
> Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
> Cc: Alexander Duyck <aduyck@mirantis.com>
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
> Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Looks good.  I'm surprised we had such a difference in how this was
handled between the flow based and device based paths.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
