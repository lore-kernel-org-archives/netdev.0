From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/4] bpf: move context info out of the verifier
Date: Tue, 17 Oct 2017 11:39:36 +0200
Message-ID: <59E5CFD8.2010807@iogearbox.net>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41529 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751961AbdJQJjh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:39:37 -0400
In-Reply-To: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 01:40 AM, Jakub Kicinski wrote:
> Hi!
>
> Daniel pointed out during the review of my previous patchset that
> the knowledge about context doesn't really belong directly in the
> verifier.  This patch set takes a bit of a drastic approach to
> move the info out of there.  I want to be able to use different
> set of verifier_ops for program analysis.  To do that, I have
> to first move the test_run callback to a separate structure.  Then
> verifier ops can be declared in the verifier directly and
> different sets can be picked for verification vs analysis.

Looks great, thanks for following up on this!
