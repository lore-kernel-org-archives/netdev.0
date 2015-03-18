From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2] tc: m_bpf: fix next arg selection after tc
 opcode
Date: Wed, 18 Mar 2015 11:00:23 +0100
Message-ID: <20150318100023.GC1992@nanopsycho.orion>
References: <1af5314868a14e738b049319dc2c21102134bc9b.1426669396.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35706 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932930AbbCRKA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:00:28 -0400
Received: by wibdy8 with SMTP id dy8so85451539wib.0
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 03:00:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1af5314868a14e738b049319dc2c21102134bc9b.1426669396.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 18, 2015 at 10:13:34AM CET, daniel@iogearbox.net wrote:
>Next argument after the tc opcode/verdict is optional, using NEXT_ARG()
>requires to have another argument after that one otherwise tc will bail
>out. Therefore, we need to advance to the next argument manually as done
>elsewhere.
>
>Fixes: 86ab59a6660f ("tc: add support for BPF based actions")
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks for fixing this Daniel.

Acked-by: Jiri Pirko <jiri@resnulli.us>
