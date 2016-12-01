From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Thu, 1 Dec 2016 17:28:50 +0100
Message-ID: <20161201162850.GB31300@pox.localdomain>
References: <cover.1480522144.git.tgraf@suug.ch>
 <950bbc4f82150683dd87e26dbd41412c26a38eba.1480522144.git.tgraf@suug.ch>
 <584012CC.4030004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, tom@herbertland.com,
        roopa@cumulusnetworks.com, hannes@stressinduktion.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36853 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbcLAQ3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:29:18 -0500
Received: by mail-wm0-f48.google.com with SMTP id g23so304800478wme.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 08:28:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <584012CC.4030004@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/16 at 01:08pm, Daniel Borkmann wrote:
> For the verifier change in may_access_direct_pkt_data(), would be
> great if you could later on follow up with a selftest-suite case,
> one where BPF_PROG_TYPE_LWT_IN/OUT prog tries to write and fails,
> and one where BPF_PROG_TYPE_LWT_IN/OUT prog uses pkt data to pass
> to helpers, for example, so that we can keep testing it when future
> changes in that area are made. Thanks.

Good idea, will do.
