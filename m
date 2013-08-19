From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Fix stack corruption on some architectures
Date: Tue, 20 Aug 2013 02:31:48 +0400
Message-ID: <52129CD4.1060200@cogentembedded.com>
References: <1376944647.5082.12.camel@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376944647.5082.12.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/20/2013 12:37 AM, Daniel Gimpelevich wrote:

> There is no need to get an interface specification if we know it's the
> wrong one; trivial change.

    Is it related to stack corruption? If not, it's asking to be in a separate 
patch.

> The big thing, though, was explained in the
> #mipslinux IRC channel:
> [Mon 2013-08-19 12:28:21 PM PDT] <headless> guys, are you sure it's not "DMA off stack" case?
> [Mon 2013-08-19 12:28:35 PM PDT] <headless> it's a known stack corruptor on non-coherent arches
> [Mon 2013-08-19 12:31:48 PM PDT] <DonkeyHotei> headless: for usb/ehci?
> [Mon 2013-08-19 12:34:11 PM PDT] <DonkeyHotei> headless: explain
> [Mon 2013-08-19 12:35:38 PM PDT] <headless> usb_control_msg() (or other such func) should not use buffer on stack. DMA from/to stack is prohibited
> [Mon 2013-08-19 12:35:58 PM PDT] <headless> and EHCI uses DMA on control xfers (as well as all the others)

    That headless was me. :-)

> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>

WBR, Sergei
