From: Johan Hovold <johan@kernel.org>
Subject: Re: [2/2] zd1211rw: fix NULL-deref at probe
Date: Wed, 22 Mar 2017 14:24:59 +0100
Message-ID: <20170322132459.GD10130@localhost>
References: <20170313124421.28587-2-johan@kernel.org>
 <20170322090415.BE414609FF@smtp.codeaurora.org>
 <20170322124548.GC10130@localhost>
 <87r31p31nv.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Daniel Drake <dsd@gentoo.org>,
        Ulrich Kunitz <kune@deine-taler.de>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87r31p31nv.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 22, 2017 at 03:02:12PM +0200, Kalle Valo wrote:
> Johan Hovold <johan@kernel.org> writes:
> 
> > On Wed, Mar 22, 2017 at 09:04:15AM +0000, Kalle Valo wrote:
> >> Johan Hovold <johan@kernel.org> wrote:
> >> > Make sure to check the number of endpoints to avoid dereferencing a
> >> > NULL-pointer or accessing memory beyond the endpoint array should a
> >> > malicious device lack the expected endpoints.
> >> > 
> >> > Fixes: a1030e92c150 ("[PATCH] zd1211rw: Convert installer CDROM
> >> > device into WLAN device")
> >> > Cc: Daniel Drake <dsd@gentoo.org>
> >> > Signed-off-by: Johan Hovold <johan@kernel.org>
> >> 
> >> Patch applied to wireless-drivers-next.git, thanks.
> >> 
> >> ca260ece6a57 zd1211rw: fix NULL-deref at probe
> >
> > What about patch 1/2 which fixes the same bug (literally copied from the
> > zd1211rw driver)?
> 
> I will apply that to my separate ath.git tree, just didn't get to your
> patch yet.

Ah, ok. 

> > And as these fixes should be backported to stable (I left out the tag
> > for networking drivers)
> 
> Actually for wireless drivers you should add the stable tag.

Alright, will do in the future.

> > why only apply to -next?
> 
> I didn't see that the fix was important enough for 4.11.

Ok, but fixes for these types of crashes that can be triggered by a
malicious device have typically gone into the current -rc (a couple just
went in through the net tree for example).

Thanks,
Johan
