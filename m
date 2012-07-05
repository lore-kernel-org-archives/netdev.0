From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] NFC: Don't warn when closing uninitialized socket
Date: Thu, 5 Jul 2012 17:45:54 +0200
Message-ID: <20120705154554.GJ18200@sortiz-mobl>
References: <1341228702-9924-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341228702-9924-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

On Mon, Jul 02, 2012 at 01:31:42PM +0200, Sasha Levin wrote:
> It is possible to close a NFC socket without initializing it first,
> there's no need to warn about it.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  net/nfc/llcp/llcp.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
I already fixed this one, with your reported-by.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
