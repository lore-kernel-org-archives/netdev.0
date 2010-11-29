From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2] add netdev led trigger
Date: Mon, 29 Nov 2010 11:15:51 +0100
Message-ID: <87ipzgl9k8.fsf@basil.nowhere.org>
References: <1290998056-8310-1-git-send-email-ecc@cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	Richard Purdie <rpurdie@rpsys.net>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org
To: Eric Cooper <ecc@cmu.edu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1290998056-8310-1-git-send-email-ecc@cmu.edu> (Eric Cooper's
	message of "Sun, 28 Nov 2010 21:34:16 -0500")
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Cooper <ecc@cmu.edu> writes:

> Add a netdev LED trigger for all Blinkenlights lovers...
> Originally taken from https://dev.openwrt.org/ticket/2776
> Slightly updated for 2.6.24 by Mickey Lauer <mickey@openmoko.org>
> and for 2.6.36 by Eric Cooper <ecc@cmu.edu>

You should really send this to netdev too.

Some comments:

The timer seems power unfriendly -- it will always tick even if nothing 
happens.

Using the device name as an identifier is not reliable, they may 
not be unique.

rwlocks are deprecated.

your store code has a off by one I think, it's possible to put 
not 0 terminated data in the string.


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
