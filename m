From: Andi Kleen <ak@suse.de>
Subject: Re: 100 network limit
Date: Thu, 28 Aug 2003 21:08:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828210855.58759b69.ak@suse.de>
References: <20030828180019.GH12541@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20030828180019.GH12541@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 04:00:19 +1000
Anton Blanchard <anton@samba.org> wrote:


> Anyway as a short term fix Jamal suggested making a sysctl for this
> maximum. If fixing this all properly is out of the question for 2.6,
> would the sysctl approach be satisfactory? The other option is to just
> bump the limit and recognise that the user is on his own if performance
> sucks.

You could just add a bitmap with a reasonable upper limit (1024?) and use 
find_first_zero_bit()  I doubt doing that would be very intrusive.

-Andi
