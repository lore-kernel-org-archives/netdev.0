From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH] fm10k: Add skb->xmit_more support
Date: Fri, 10 Oct 2014 21:12:03 +0000
Message-ID: <D05D98E2.5B584%matthew.vick@intel.com>
References: <20141010201714.20593.67813.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24218 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292AbaJJVNp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 17:13:45 -0400
In-Reply-To: <20141010201714.20593.67813.stgit@ahduyck-workstation.home>
Content-Language: en-US
Content-ID: <31EBFFEE7C31954D8DF201AB47652894@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/14, 1:17 PM, "alexander.duyck@gmail.com"
<alexander.duyck@gmail.com> wrote:

>From: Alexander Duyck <alexander.h.duyck@redhat.com>
>
>This change adds suport for skb->xmit_more based on the changes that were
>made to igb to support the feature.  The main changes are moving up the
>check for maybe_stop_tx so that we can check netif_xmit_stopped to
>determine
>if we must write the tail because we can add no further buffers.
>
>Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

s/suport/support in the first line of the patch description, but other
than that this looks good to me. Thanks, Alex!

Acked-by: Matthew Vick <matthew.vick@intel.com>
