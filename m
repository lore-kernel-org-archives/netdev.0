From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH 02/14] ALSA: portman2x4: return proper error values from
 attach
Date: Wed, 8 Apr 2015 19:10:25 +0530
Message-ID: <20150408134025.GA12139@sudip-PC>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-3-git-send-email-sudipm.mukherjee@gmail.com>
 <55252E09.2060600@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jean Delvare <jdelvare@suse.de>,
	Wolfram Sang <wsa@the-dreams.de>,
	Rodolfo Giometti <giometti@enneenne.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Mark Brown <broonie@kernel.org>,
	Willy Tarreau <willy@meta-x.org>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>,
	linux-kernel@vger.kernel.org, linux-i2c@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-spi@vger.kernel.org, devel@driverdev.osuosl.org,
	alsa-devel@alsa-project.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55252E09.2060600@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 08, 2015 at 04:32:57PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 4/8/2015 2:20 PM, Sudip Mukherjee wrote:
> 
> >now that we are monitoring the return value from attach, make the
> 
>    So you've first changed the method prototype and follow up with
> the changes to the actual implementations? That's backward. I'm
> afraid such changes can't be done piecemeal.
Dan Carpenter has exlained me the problem with this aproach. I have
already sent a v2 which doesnot break anything and if everyone approves
that way then we can change one driver at a time and nothing will
break.

regards
sudip

> 
