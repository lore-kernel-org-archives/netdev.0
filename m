From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 0/8]  Add support for offloading
 packet-sampling
Date: Tue, 15 Nov 2016 10:27:43 +0100
Message-ID: <20161115092743.GA1783@nanopsycho.orion>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34808 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755343AbcKOJ1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 04:27:47 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so23757888wme.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 01:27:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 14, 2016 at 04:00:30PM CET, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>Add the sample tc action, which allows to sample packet matching
>a classifier. The sample action peeks randomly packets, duplicates them,
>truncates them and adds informative metadata on the packet, for example,
>the input interface and the original packet length. The sampled packets
>are marked to allow matching them and redirecting them to a specific
>collector device.
>
>The sampled packets metadata is packed using ife encapsulation. To do
>that, this patch-set extracts ife logics from the tc_ife action into an
>independent ife module, and uses that functionality to pack the metadata.
>To include all the needed metadata, this patch-set introduces some new
>IFE_META tlv types.
>
>In addition, Add the support for offloading the macthall-sample tc command
>in the Mellanox mlxsw driver, for ingress qdiscs.
>
>Userspace examples for that code can be found in:
> - https://github.com/yotamgi/host-sflow: sflow client that uses the sample
>   with combination of tap device to sample packets and send to a
>   centralized sflow collector.
> - https://github.com/yotamgi/libife: a library for manipulating ife
>   packets in userspace. The library is used in the host-sflow program to
>   parse the sampled packets.

Dave, please drop this patchset for now. We just discovered couple of
more changes are needed.

Thanks
