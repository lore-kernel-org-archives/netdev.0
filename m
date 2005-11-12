From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC: 2.6 patch] remove ISA legacy functions
Date: Sat, 12 Nov 2005 00:08:29 -0500
Message-ID: <437578CD.1080501@pobox.com>
References: <20051107200336.GH3847@stusta.de> <20051110042857.38b4635b.akpm@osdl.org> <20051111021258.GK5376@stusta.de> <20051110182443.514622ed.akpm@osdl.org> <20051111201849.GP5376@stusta.de> <20051111202005.GQ5376@stusta.de> <20051111203601.GR5376@stusta.de> <20051112045216.GY5376@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	jonathan@buzzard.org.uk, tlinux-users@tce.toshiba-dme.co.jp,
	Jaroslav Kysela <perex@suse.cz>
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051112045216.GY5376@stusta.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch removes the ISA legacy functions that are deprecated since 
> kernel 2.4 and that aren't available on all architectures.
> 
> The 7 drivers that were still using this obsolete API are now marked
> as BROKEN.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

it's not valid to mark working drivers broken, IMO.

Mark them x86-only, perhaps.

	Jeff



