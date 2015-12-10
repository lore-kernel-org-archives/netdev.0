From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 1/4] list: introduce list_is_first()
Date: Thu, 10 Dec 2015 08:10:34 -0700
Message-ID: <566995EA.80509@kernel.dk>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josh Poimboeuf <jpoimboe@redhat.com>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@163.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/10/2015 07:17 AM, Geliang Tang wrote:
> We already have list_is_last(), it makes sense to also add
> list_is_first() for consistency. This list utility function
> to check for first element in a list.

Honestly, I think we already have way too many of these kind of helpers. 
IMHO they don't really help, they hurt readability. You should know how 
the list works anyway, and if you do, then it's a no-brainer what's 
first and last. If you don't, then you are bound to screw up in other ways.

Just my 2 cents.

-- 
Jens Axboe
