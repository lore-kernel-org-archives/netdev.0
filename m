From: Ingo Molnar <mingo@elte.hu>
Subject: [build bug] drivers/built-in.o: In function `rt2x00leds_resume': :
	undefined reference to `led_classdev_resume'
Date: Sun, 20 Apr 2008 10:13:02 +0200
Message-ID: <20080420081302.GA11954@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ian Schram <ischram@telenet.be>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Ivo van Doorn <ivdoorn@gmail.com>
To: David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Tomas Winkler <tomas.winkler@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> a third -git build failure triggered in last night's x86.git 
> build/boot testing:

and after i restarted last night's QA run, within a few iterations a 
fourth build failure popped up:

  drivers/built-in.o: In function `rt2x00leds_resume':
  : undefined reference to `led_classdev_resume'
  drivers/built-in.o: In function `rt2x00leds_resume':
  : undefined reference to `led_classdev_resume'
  [...]

config:

  http://redhat.com/~mingo/misc/config-Sun_Apr_20_09_43_01_CEST_2008.bad

suspected commit is: a2e1d52a32 "rt2x00: Remove MAC80211_LEDS 
dependency".

so far the -git track record: 4 networking build failures 1 SCSI build 
failure. (and i'm not picking these bugs nor am i trying to pick any 
fight here - randconfig does)

... and i think a little bit of grumpiness might be in order now: none 
of these commits were announced on lkml, so i have to hijack this thread 
again. As exciting as reporting bugs might seem from the outside, i'm 
supposed to find x86 and scheduler bugs, not networking bugs. Really, 
your practice of removing networking commits and pull requests from lkml 
does not result in a stellar quality track record.

	Ingo
