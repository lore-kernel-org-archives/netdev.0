From: Barry Day <briselec@gmail.com>
Subject: Re: [PATCH] rtl8xxxu: Fix for agressive power saving by rtl8723bu
 wireless IC
Date: Tue, 1 Nov 2016 08:20:46 +1000
Message-ID: <20161031222045.GA14900@testbox>
References: <20161031183522.GA13315@cube>
 <wrfj1sywrz2f.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heenan <john@zgus.com>, Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <wrfj1sywrz2f.fsf@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 31, 2016 at 05:25:12PM -0400, Jes Sorensen wrote:
> As mentioned previously, if this is to be changed here, it has to be
> matched in the _stop section too. It also has to be investigated exactly
> why this matters for 8723bu. It is possible this matters for other
> devices, but we need to find out exactly what causes this not moving a
> major block of init code around like this.
>

I've tested this on the 8192e and 8192c. The same problems occurs with the
8192e but not the 8192c. Stopping and restarting wpa_supplicant had
no affect on the 8192c ability to connect to an AP.
