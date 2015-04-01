From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH iproute2 -next v2] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Wed, 1 Apr 2015 23:15:26 +0100
Message-ID: <20150401221526.GA19425@casper.infradead.org>
References: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, ast@plumgrid.com, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58410 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbbDAWP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 18:15:28 -0400
Content-Disposition: inline
In-Reply-To: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/15 at 05:57pm, Daniel Borkmann wrote:
> This work finalizes both eBPF front-ends for the classifier and action
> part in tc, it allows for custom ELF section selection, a simplified tc
> command frontend (while keeping compat), reusing of common maps between
> classifier and actions residing in the same object file, and exporting
> of all map fds to an eBPF agent for handing off further control in user
> space.
> 
> It also adds an extensive example of how eBPF can be used, and a minimal
> self-contained example agent that dumps map data. The example is well
> documented and hopefully provides a good starting point into programming
> cls_bpf and act_bpf.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

The examples for both the classifier/action and the map fd handover
are very nicely written and help a lot to understand how all of
this works.

FWIW:
Acked-by: Thomas Graf <tgraf@suug.ch>
