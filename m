From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] checkpatch: Add some --strict coding style checks
Date: Tue, 21 Feb 2012 15:16:11 -0800
Message-ID: <1329866171.5143.16.camel@joe2Laptop>
References: <20120221151435.GA19354@tuxdriver.com>
	 <20120221.144417.1445117001833888214.davem@davemloft.net>
	 <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
	 <20120221.154053.2103818562080068513.davem@davemloft.net>
	 <1329857959.5143.11.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Whitcroft <apw@shadowen.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"andrei.emeltchenko.news@gmail.com"
	<andrei.emeltchenko.news@gmail.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-02-21 at 22:09 +0000, Allan, Bruce W wrote:
> This appears to falsely complain about parenthesis alignment in
> conditional statements with multiple opening parentheses.  For
> example, these will report a check condition:
> 
> 	if (test_and_set_bit(nr,
> 				   addr))
> 		baz();
> 
> 	if (!(func_a(x) &&
> 		func_b(y)))
> 		baz();
> 
> Assuming my stupid mailer will screw up the indentation above, the 'a'
> in addr in the first example is meant to be immediately below the 'n'
> in nr, and the two 'f's in func_* are meant to be vertically lined up
> in the second example.

You're right, thanks for testing.
The logic I used is too trivial.

Andrew, please ditch this one for awhile.
