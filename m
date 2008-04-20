From: Ingo Molnar <mingo@elte.hu>
Subject: [build bug] iwl-3945-led.c:(.text+0x119e36): undefined reference
	to `__led_classdev_unregister'
Date: Sun, 20 Apr 2008 09:34:41 +0200
Message-ID: <20080420073441.GA31745@elte.hu>
References: <20080419135602.GA2499@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ian Schram <ischram@telenet.be>,
	Tomas Winkler <tomas.winkler@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Tomas Winkler <tomas.winkler@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080419135602.GA2499@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> here's another networking (iwlwifi) related build failure with latest 
> -git:

a third -git build failure triggered in last night's x86.git build/boot 
testing:

 drivers/built-in.o: In function `iwl3945_led_unregister_led':
  iwl-3945-led.c:(.text+0x119e36): undefined reference to `__led_classdev_unregister'
 drivers/built-in.o: In function `iwl3945_led_register_led':
  iwl-3945-led.c:(.text+0x119ecd): undefined reference to `led_classdev_register'

config:

 http://redhat.com/~mingo/misc/config-Sat_Apr_19_22_08_04_CEST_2008.bad

probably due to commit ab53d8af6 "iwlwifi: Add led support".

	Ingo
