From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 11/11] netlink: add documentation for memory mapped I/O
Date: Mon, 20 Aug 2012 12:32:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208201224430.8114@frira.zrqbmnf.qr>
References: <1345443532-3707-1-git-send-email-kaber@trash.net> <1345443532-3707-12-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Florian.Westphal@Sophos.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-12-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2012-08-20 08:18, Patrick McHardy wrote:
>+
>+RX and TX rings
>+----------------
>+
>+Each ring contains a number of continous memory blocks, containing frames of
>+fixed size dependant on the parameters used for ring setup.

dependent

>+The blocks are only visible to the kernel, from the point of view of user-space
>+the ring just contains the frames in a continous memory zone.

...to the kernel; from the user-space point of view, the ring...

continuous (multiple occurrences)

>+Ring frames
>+------------
>+
>+Each frames contain a frame header, consisting of a synchronization word and some

Each frame contains a frame header,

>+The possible values in the status word are:
>+
>+- NL_MMAP_STATUS_UNUSED:
>+	RX ring:	frame belongs to the kernel and contains no message

The frame (mult)

>+			for user-space. Approriate action is to invoke poll()
>+			to wait for new messages.

The appropriate (mult)

>+			if (hdr->nm_status == NL_MMAP_STATUS_VALID)
>+				/* Regular memory mapped frame */
>+				nlh = (void *hdr) + NL_MMAP_HDRLEN;

(void *)hdr + NL_MMAP_HDRLEN

