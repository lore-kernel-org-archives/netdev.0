From: Johan Hovold <johan@kernel.org>
Subject: Re: [2/2] zd1211rw: fix NULL-deref at probe
Date: Wed, 22 Mar 2017 13:45:48 +0100
Message-ID: <20170322124548.GC10130@localhost>
References: <20170313124421.28587-2-johan@kernel.org>
 <20170322090415.BE414609FF@smtp.codeaurora.org>
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
In-Reply-To: <20170322090415.BE414609FF@smtp.codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 22, 2017 at 09:04:15AM +0000, Kalle Valo wrote:
> Johan Hovold <johan@kernel.org> wrote:
> > Make sure to check the number of endpoints to avoid dereferencing a
> > NULL-pointer or accessing memory beyond the endpoint array should a
> > malicious device lack the expected endpoints.
> > 
> > Fixes: a1030e92c150 ("[PATCH] zd1211rw: Convert installer CDROM device into WLAN device")
> > Cc: Daniel Drake <dsd@gentoo.org>
> > Signed-off-by: Johan Hovold <johan@kernel.org>
> 
> Patch applied to wireless-drivers-next.git, thanks.
> 
> ca260ece6a57 zd1211rw: fix NULL-deref at probe

What about patch 1/2 which fixes the same bug (literally copied from the
zd1211rw driver)?

And as these fixes should be backported to stable (I left out the tag
for networking drivers), why only apply to -next?

Thanks,
Johan
