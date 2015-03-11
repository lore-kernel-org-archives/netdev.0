From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC v2] ath10k: move code from parameter list into a
 function
Date: Wed, 11 Mar 2015 20:10:10 +0100
Message-ID: <1426101010.1904.9.camel@sipsolutions.net>
References: <1426100519-20636-1-git-send-email-hofrat@osadl.org>
	 (sfid-20150311_200723_379167_2BC79246)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>, Valdis.Kletnieks@vt.edu,
	Bj??rn Mork <bjorn@mork.no>,
	Jeff Haran <Jeff.Haran@citrix.com>,
	Pat Erley <pat-lkml@erley.org>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426100519-20636-1-git-send-email-hofrat@osadl.org> (sfid-20150311_200723_379167_2BC79246)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-03-11 at 15:01 -0400, Nicholas Mc Guire wrote:
> Putting code into the parameter list of wait_event_timeout() might be
> legal C-code but not really readable - the "inline" code is simply
> moved into a function and that passed to wait_event_timeout() as the
> condition.

Arguably, that's even more unreadable since if you don't know this macro
well you might assume the function is called only once, which is clearly
not true...

Don't get me wrong, I'm not opposed to this change, but if you ask me
it's not completely clear that this makes it more readable.

johannes
