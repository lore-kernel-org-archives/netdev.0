From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Wed, 4 Jan 2017 17:48:48 -0500
Message-ID: <20170104224848.GB31756@oracle.com>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com>
 <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
 <586D7437.1050708@iogearbox.net>
 <20170104222224.GA31756@oracle.com>
 <586D7692.4000604@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        willemb@google.com, davem@davemloft.net, shuah@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24397 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936243AbdADWtK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 17:49:10 -0500
Content-Disposition: inline
In-Reply-To: <586D7692.4000604@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 23:26), Daniel Borkmann wrote:
> 
> >>As it stands it makes it a bit harder to parse / less readable with macros
> >>actually. Rest seems fine, thanks.

Usually macros are there (a) as an abstraction so you 
dont have to hard-code things, and, (b) to make things 
more readable. (maybe that's why the 1992 VJ paper on 
BPF came up with these macros?)

I think we differ on code-aesthetics (not correctness) here. 
It was not immediately obvious to me that "0x15 is actually 
BPF_JMP + BPF_JEQ + BPF_K" etc, when I wanted to extend
the bpf_prog to harden the checks in the existing code.

Would it be ok to leave the extremely subjective 
"make this more readable" part for you to tackle later? 
Or I can just drop patch1, and you can fix it to your 
satisfaction later.

--Sowmini
