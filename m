From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] ethernet: fm10k: Actually drop 4 bits
Date: Sat, 24 Jan 2015 01:50:06 +0100
Message-ID: <87twzhknnl.fsf@rasmusvillemoes.dk>
References: <1421967198-16667-1-git-send-email-linux@rasmusvillemoes.dk>
	<D0E81E0C.682EB%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel\@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Vick\, Matthew" <matthew.vick@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D0E81E0C.682EB%matthew.vick@intel.com> (Matthew Vick's message
	of "Sat, 24 Jan 2015 00:18:59 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 24 2015, "Vick, Matthew" <matthew.vick@intel.com> wrote:

> Good catch! I noticed this too and was getting a patch together to address
> this.
>
> The difference is that I was planning on not silently accepting an invalid
> VLAN ID to begin with and returning FM10K_ERR_PARAM if the VLAN was
> invalid, which I think is a better approach for this situation. If it's
> alright with you, I'll generate the patch shortly and credit you via your
> Reported-by.

Sure, do what you think is best.

Rasmus
