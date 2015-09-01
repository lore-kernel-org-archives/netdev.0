From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mwifiex: Make mwifiex_dbg a function, reduce object size
Date: Tue, 01 Sep 2015 08:16:00 -0700
Message-ID: <1441120560.3012.30.camel@perches.com>
References: <1441043205.3276.28.camel@perches.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB8B595@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB8B595@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-01 at 15:09 +0000, David Laight wrote:
> From: Joe Perches
> > Sent: 31 August 2015 18:47
> > 
> > The mwifiex_dbg macro has two tests that could be consolidated
> > into a function reducing overall object size ~10KB (~4%).
> > 
> > So convert the macro into a function.
> 
> This looks like it will slow things down somewhat.

I doubt in any meaningful way.
