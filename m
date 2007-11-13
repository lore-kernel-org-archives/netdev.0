From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 07:57:54 -0800
Message-ID: <2c0942db0711130757g295add20re0ee423b84921d28@mail.gmail.com>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	 <20071113.033946.114918709.davem@davemloft.net>
	 <20071113034916.2556edd7.akpm@linux-foundation.org>
	 <20071113.035824.40509981.davem@davemloft.net>
	 <20071113041259.79c9a8c5.akpm@linux-foundation.org>
	 <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>
	 <4739C1B0.8000803@cateee.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Mark Lord" <liml@rtr.ca>, "Ingo Molnar" <mingo@elte.hu>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: "Giacomo A. Catenazzi" <cate@cateee.net>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <4739C1B0.8000803@cateee.net>
Content-Disposition: inline
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Nov 13, 2007 7:24 AM, Giacomo A. Catenazzi <cate@cateee.net> wrote:
> As a long time kernel tester, I see some problem with the
> newer "new development model". In the short merge windows,
> after to much time, there are to many patches.

I think the root issue there is that it's hard to get all testers to
run a bisect, but easy to ask them to test snapshots. Right now the
snapshots are generated nightly, but I think it would make more sense
if they were generated every N patches, for some value of N...

Of course, for that to really work, we have to ensure that the result
is always compilable, which has been getting better, but not perfect.

Ray
