From: Bruce Liu <damuzi000@gmail.com>
Subject: Re: [PATCH 1/1] When timestamping is enabled, stmmac_tx_clean will
 call stmmac_get_tx_hwtstamp to get tx TS. It's possible that skb is NULL
 because there are other network frames that use several descriptors. So we
 must return immediately in stmmac_get_tx_hwtstamp if skb is NULL to avoid
 system crash.
Date: Mon, 13 Jan 2014 21:54:33 +0800
Message-ID: <20140113135431.GA1956@gmail.com>
References: <1389492095-6589-1-git-send-email-damuzi000@gmail.com>
 <20140112093951.GA3743@gmail.com>
 <52D27EB4.9050909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52D27EB4.9050909@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 12, 2014 at 12:38:28PM +0100, Daniel Borkmann wrote:
> On 01/12/2014 10:39 AM, Bruce Liu wrote:
> >  When timestamping is enabled, stmmac_tx_clean will call stmmac_get_tx_hwtstamp to get tx TS.
> >  It's possible that skb is NULL because there are other network frames that use several descriptors.
> >  So we must return immediately in stmmac_get_tx_hwtstamp if skb is NULL to avoid system crash.
> >
> >
> >Signed-off-by: Bruce Liu <damuzi000@gmail.com>
> 
> Please see Documentation/SubmittingPatches +489
> 
> You subject line is way too long and should just be something like:
> 
> [PATCH net-next] net: stmmac: fix NULL pointer dereference in stmmac_get_tx_hwtstamp
> 
> Don't indent your actual commit message with whitespaces as prefix,
> and do a line break after around 70 chars.
> 
> Btw, I mentioned net-next in the subject since merge window will
> open soon anyway.
> 

Thanks, and I'll resend the patch.

Bruce.
