From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH v2] drivers/net/usb/asix:  resync from vendor's copy
Date: Thu, 10 Nov 2011 09:01:26 -0500
Message-ID: <4EBBD936.40705@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net> <4EA8B283.3010105@teksavvy.com> <20111026.221719.2216112919297458522.davem@davemloft.net> <4EB19BBE.5050602@teksavvy.com> <4EBAB8F5.1010101@teksavvy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Michal Marek <mmarek@suse.cz>,
	Grant Grundler <grundler@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EBAB8F5.1010101@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11-11-09 12:31 PM, Mark Lord wrote:
> Second pass (for review) at updating the in-kernel asix usb/network driver
> from the v4.1.0 vendor GPL version of the driver, obtained from here:
> 
>   http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver
> 
> The original vendor copy used a local "axusbnet" middleware (rather than "usbnet").
> I've converted it back to using "usbnet", made a ton of cosmetic changes
> to get it to pass checkpatch.pl, and removed a small amount of code duplication.
> 
> The tx/rx checksum code has been updated per Ben's comments,
> and the duplicated MII_* definitions have been removed.
> I've changed the version string to be "4.1.0-kernel",
> to reflect the vendor's code version while also distinguishing
> this port from the original vendor code.
> 
> It can use more work going forward, but it is important to get it upstream
> sooner than later -- the current in-kernel driver fails with many devices,
> both old and new.  This updated version works with everything I have available
> to test with, and also handles suspend / resume (unlike the in-kernel one).
> 
> Signed-off-by: Mark Lord <mlord@pobox.com>
...

Okay, the vendor has told me to cease development on this now.
They prefer instead to feed small parts of their mainline driver
to Grant Grundler as issues arise, rather than to get the whole
thing upstream.

So be it.

Cheers
