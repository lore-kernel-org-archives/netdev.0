From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 3/3] ser_gigaset: remove unnecessary kfree() calls from
 release method
Date: Wed, 09 Dec 2015 00:15:50 +0100
Message-ID: <1449616550.2384.39.camel@tiscali.nl>
References: <cover.1449570042.git.tilman@imap.cc>
	 <61b60d7eff05eddf305460f3dae2b80221f08aad.1449570042.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <61b60d7eff05eddf305460f3dae2b80221f08aad.1449570042.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tilman,

On di, 2015-12-08 at 12:00 +0100, Tilman Schmidt wrote:
> device->platform_data and platform_device->resource are never used
> and remain NULL through their entire life. Drops the kfree() calls
> for them from the device release method.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> Reported-by: Paul Bolle <pebolle@tiscali.nl>

s/Reported-by/Acked-by/

(Having both lines would be overdoing things.)

Thanks,


Paul Bolle
