From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtlwifi: Add missing newlines to RT_TRACE calls
Date: Sun, 26 Jun 2016 18:26:19 -0700
Message-ID: <1466990779.1847.78.camel@perches.com>
References: <5677791872bfb47963780c198c825d882456720f.1466969647.git.joe@perches.com>
	 <577070D9.5080503@lwfinger.net> <1466990029.1847.74.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466990029.1847.74.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-06-26 at 18:13 -0700, Joe Perches wrote:
> On Sun, 2016-06-26 at 19:18 -0500, Larry Finger wrote:
> > 
> > On 06/26/2016 02:34 PM, Joe Perches wrote:
> > > 
> > > 
> > > RT_TRACE does not add a newline to the end of a message and always
> > > emits at KERN_DEBUG so these are susceptible to message
> > > interleaving
> > > from other processes without the newline.
> > > 
> > > Signed-off-by: Joe Perches <joe@perches.com>
> > > ---
> > This patch does not apply to the wireless-drivers-next repo. Which
> > one
> > did you use?
> linux-next

btw: both patches seem to apply to wireless-drivers-next just fine.

$ git rev-parse HEAD
1bb57c8a5e33bcbec031ce0c629968922d5af89d
$ git am ../next/0001-rtlwifi-Create-_rtl_dbg_trace-function-to-reduce-RT_.patch
Applying: rtlwifi: Create _rtl_dbg_trace function to reduce RT_TRACE code size
$ git am ../next/0001-rtlwifi-Add-missing-newlines-to-RT_TRACE-calls.patch
Applying: rtlwifi: Add missing newlines to RT_TRACE calls
