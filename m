From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next] tc: flower: support for matching MPLS
 labels
Date: Wed, 20 Sep 2017 18:09:17 -0700
Message-ID: <20170920180917.17022585@xeon-e3>
References: <1505225175-13830-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:55517 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751681AbdIUBJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 21:09:21 -0400
Received: by mail-pf0-f169.google.com with SMTP id r71so2394331pfe.12
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 18:09:21 -0700 (PDT)
In-Reply-To: <1505225175-13830-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Sep 2017 16:06:15 +0200
Simon Horman <simon.horman@netronome.com> wrote:

> From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> 
> This patch adds support to the iproute2 tc filter command for matching MPLS
> labels in the flower classifier.  The ability to match the Time To Live,
> Bottom Of Stack, Traffic Control and Label fields are added as options to
> the flower filter.
> 
> e.g.:
>   tc filter add dev eth0 protocol 0x8847 parent ffff: \
>     flower mpls_label 1 mpls_tc 2 mpls_ttl 3 mpls_bos 0 \
>     action drop
> 
> Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Looks good, applied
