From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] remove check_region from PnPWakeUp routine of Eepro ISA
 driver
Date: Wed, 21 Sep 2005 23:37:08 -0700
Message-ID: <20050921233708.553c9d2f.akpm@osdl.org>
References: <20050922060030.GB19049@gollum.tnic>
	<20050921230915.364f0ac9.akpm@osdl.org>
	<20050922062943.GA31805@gollum.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750933AbVIVGhu@vger.kernel.org>
To: Borislav Petkov <petkov@uni-muenster.de>
In-Reply-To: <20050922062943.GA31805@gollum.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Borislav Petkov <petkov@uni-muenster.de> wrote:
>
> > That being said, the code you've modified is disabled due to
>  > !defined(PnPWakeup), and the chances of anyone ever changing that are close
>  > to zero.
>  should I remove it then altogether?

We might as well leave it there in case someone is inspired to reenable the
feature and work on the driver a bit.  The chances of that are near zero -
it's ancient.  I don't think there's much point in spending time on this
driver.
