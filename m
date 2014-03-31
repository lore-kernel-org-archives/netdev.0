From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/9] BPF updates
Date: Mon, 31 Mar 2014 00:46:16 -0400 (EDT)
Message-ID: <20140331.004616.1557779324959569233.davem@davemloft.net>
References: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaCaEqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 00:46:21 -0400
In-Reply-To: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 28 Mar 2014 18:58:17 +0100

> We sat down and have heavily reworked the whole previous patchset
> from v10 [1] to address all comments/concerns. This patchset therefore
> *replaces* the internal BPF interpreter with the new layout as
> discussed in [1], and migrates some exotic callers to properly use the
> BPF API for a transparent upgrade. All other callers that already use
> the BPF API in a way it should be used, need no further changes to run
> the new internals. We also removed the sysctl knob entirely, and do not
> expose any structure to userland, so that implementation details only
> reside in kernel space. Since we are replacing the interpreter we had
> to migrate seccomp in one patch along with the interpreter to not break
> anything. When attaching a new filter, the flow can be described as
> following: i) test if jit compiler is enabled and can compile the user
> BPF, ii) if so, then go for it, iii) if not, then transparently migrate
> the filter into the new representation, and run it in the interpreter.
> Also, we have scratched the jit flag from the len attribute and made it
> as initial patch in this series as Pablo has suggested in the last
> feedback, thanks. For details, please refer to the patches themselves.
> 
> We did extensive testing of BPF and seccomp on the new interpreter
> itself and also on the user ABIs and could not find any issues; new
> performance numbers as posted in patch 8 are also still the same.
> 
> Please find more details in the patches themselves.
> 
> For all the previous history from v1 to v10, see [1]. We have decided
> to drop the v11 as we have pedantically reworked the set, but of course,
> included all previous feedback.

Ok, applied, thanks a lot everyone.
