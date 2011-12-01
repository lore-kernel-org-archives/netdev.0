From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 1/4] nfc: Use standard logging styles
Date: Thu, 1 Dec 2011 16:59:51 +0100
Message-ID: <20111201155951.GF22609@sortiz-mobl>
References: <cover.1322595343.git.joe@perches.com>
 <6c89a76ddb76926febe36fe5be514cb186e39a76.1322595343.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6c89a76ddb76926febe36fe5be514cb186e39a76.1322595343.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Tue, Nov 29, 2011 at 11:37:32AM -0800, Joe Perches wrote:
> Using the normal logging styles is preferred over
> subsystem specific styles when the subsystem does
> not take a specific struct.
> 
> Convert nfc_<level> specific messages to pr_<level>
> Add newlines to uses.
> 
I would be fine with moving to pr_debug, but I'd like the pr_fmt() routine to
include the function name as well.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
