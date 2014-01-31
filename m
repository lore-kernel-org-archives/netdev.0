From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] retry hw init when it fails
Date: Fri, 31 Jan 2014 06:29:21 +0100
Message-ID: <20140131052921.GA27202@kroah.com>
References: <1391145383-18652-1-git-send-email-olivier@trillion01.com>
 <1391145383-18652-2-git-send-email-olivier@trillion01.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net, linville@tuxdriver.com,
	chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Olivier Langlois <olivier@trillion01.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391145383-18652-2-git-send-email-olivier@trillion01.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 31, 2014 at 12:16:23AM -0500, Olivier Langlois wrote:
> rtl_ps_enable_nic() is called from loops that will loop until this function returns true or a
> maximum number of retries is performed.
> 
> hw_init() returns non-zero on error. In that situation return false to
> restore the original design intent to retry hw init when it fails.
> 
> Signed-off-by: Olivier Langlois <olivier@trillion01.com>
> ---
>  drivers/net/wireless/rtlwifi/ps.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)


<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

Same goes for aptch 1/2 as well...
