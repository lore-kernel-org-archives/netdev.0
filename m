From: Michael Buesch <mb@bu3sch.de>
Subject: Re: ANNOUNCE: SFLC helps developers assess ar5k (enabling free Atheros HAL)
Date: Wed, 15 Nov 2006 19:42:14 +0100
Message-ID: <200611151942.14596.mb@bu3sch.de>
References: <20061115031025.GH3451@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: madwifi-devel@lists.sourceforge.net, lwn@lwn.net, mcgrof@gmail.com,
	david.kimdon@devicescape.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030855AbWKOSo7@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061115031025.GH3451@tuxdriver.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 15 November 2006 04:10, John W. Linville wrote:
> It is my pleasure to announce that the SFLC [1] has assisted the ar5k
> developers in evaluating the development history of Reyk Floeter's
> OpenBSD reverse-engineered Atheros HAL, ar5k [2].  SFLC's assessment
> leads to the conclusion that free software developers should not be
> worried about using/extending ar5k or porting ar5k to other platforms.
> 
> In the past there were serious questions raised and even dire warnings
> made about ar5k's copyright status.  The purpose of this statement
> is to refute those claims and to publicly clarify ar5k's status
> to developers.
> 
> SFLC has made independent inquiries with the OpenBSD team regarding the
> development history of ar5k source.  The responses received provide
> a reasonable basis for SFLC to believe that the OpenBSD developers
> who worked on ar5k did not misappropriate code, and that the ar5k
> implementation is OpenBSD's original copyrighted work.
> 
> This announcement should serve to remove the cloud which has prevented
> progress towards an in-kernel driver for Atheros hardware.  This should
> be of particular interest to those involved with the DadWifi project [3].
> 
> I'd like to take this opportunity to thank the folks at the SFLC for
> their hard work, and I'd also like to personally thank Luis Rodriguez
> for the role he played in coordinating contact between the SFLC and
> the community at large.
> 
> Thanks!
> 
> John
> 
> [1] http://www.softwarefreedom.org/
> [2] http://team.vantronix.net/ar5k/
> [3] http://marc.theaimsgroup.com/?l=linux-netdev&m=116113064513921&w=2

So, who is finally going to _DO_ the work?
Some of you know that I started an atheros driver at
http://bu3sch.de/ath/atheros.git/
It's not really a driver, yet, as nobody got to continue on the specification,
so I was stuck.

Now that it seems to be ok to use these openbsd sources, should I port
them to my driver framework?
I looked over the ar5k code and, well, I don't like it. ;)
I don't really like having a HAL. I'd rather prefer a "real" driver
without that HAL obfuscation.

-- 
Greetings Michael.
