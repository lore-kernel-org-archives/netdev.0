From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Thu, 5 Jan 2017 10:54:07 -0500
Message-ID: <20170105155407.GH16822@oracle.com>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com>
 <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
 <d3e75147-475a-823c-3530-5150dd24a63d@kernel.org>
 <20170104225554.GD31756@oracle.com>
 <3be167c0-b7cb-1ab4-6afe-e2e84a3404f5@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com,
        davem@davemloft.net
To: Shuah Khan <shuah@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44613 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161609AbdAEPyb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 10:54:31 -0500
Content-Disposition: inline
In-Reply-To: <3be167c0-b7cb-1ab4-6afe-e2e84a3404f5@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 16:26), Shuah Khan wrote:
> 
> Could you please split this patch into two. Hardening part in one and
> the cleanup in a separate patch. This way I can get the hardening fix
> into 4.10 in my next Kselftest update. Cleanup patch can go in later.
> 
> thanks,
> -- Shuah

I'm a little confused by the comments above.

Dan's suggestion was that I could have used some other
tool to generate the code, rather than hand-crafting it as I did.
In his last message, he suggests that it may be ok to leave
the hand-crafted version as is (for now), as well.

To make it clear:
the current v3 version *is* the "hardening" part. Dan's suggestion is
that the hand-crafted version can be replaced by bpf_asm generated code
later. That would be the "cleanup" part, which I was going to do in a
later commit.

Does that help?

--Sowmini
