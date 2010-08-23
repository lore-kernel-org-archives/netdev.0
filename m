From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 09:57:58 -0700 (PDT)
Message-ID: <20100823165758.4624E400BF@magilla.sf.frob.com>
References: <cover.1282550649.git.richard.cochran@omicron.at>
	<201008231457.26690.arnd@arndb.de>
	<20100823134330.GM12892@parisc-linux.org>
	<201008231646.00357.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	Richard Cochran <richardcochran@gmail.com>,
	john stultz <johnstul@us.ibm.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Arnd Bergmann's message of  Monday, 23 August 2010 16:46:00 +0200 <201008231646.00357.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EOPNOTSUPP is also called ENOTSUP in userland.  ENOTSUP is the appropriate
POSIX errno code for a situation such as a clock type that cannot be used
in a certain call (like setting when you can only read it, etc.).


Thanks,
Roland
