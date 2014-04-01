From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netlink: per-protocol bind fixup/enhancement set
Date: Tue, 01 Apr 2014 17:33:54 -0400 (EDT)
Message-ID: <20140401.173354.1207821556865053650.davem@davemloft.net>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
	<cover.1396317747.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: rgb@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1396317747.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Tue,  1 Apr 2014 10:14:55 -0400

> This set provides a way for per-protocol bind functions to signal an error and
> to be able to clean up after themselves.
> 
> The first patch has already been accepted, but is included just in case to
> avoid a merge error.
> 
> The second patch adds the per-protocol bind return code to signal to the
> netlink code that no further processing should be done and to undo the work
> already done.  This rev has fixed DaveM's last issue and flattened the
> intentation as requested by Patrick McHardy by two by reworking the logic.
> 
> The third provides a way per protocol to undo actions on DROP.
> 
> Thanks for the feedback.

I would like to defer this to the next merge window.

I'd also like to see how the AUDIT code is going to use this, provide
the user in your next submission.

Right now the only user is nfnetlink and it's merely to do a
(sub-)module request.

Therefore it's no surprise that we've never had any real well thought
out semantics defined for the bind method, and it's also why we never
thought of adding an unbind method before.
