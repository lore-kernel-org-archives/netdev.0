From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [POWERPC] Fix typo #ifdef -> #ifndef
Date: Thu, 8 Nov 2007 20:35:52 -0800
Message-ID: <20071108203552.bcc1e5a8.akpm@linux-foundation.org>
References: <472CC914.3030709@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: Jochen Friedrich <jochen@scram.de>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <472CC914.3030709@scram.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

> On Sat, 03 Nov 2007 20:16:36 +0100 Jochen Friedrich <jochen@scram.de> wrote:
> Subject: [PATCH] [POWERPC] Fix typo #ifdef -> #ifndef

Please put the "powerpc" outside the [].  Because things inside [] get
removed when the receiver applies the patch, but the subsystem
identification ("powerpc") is useful information which we want to carry
into the permanent git record. (Although Paul might add it anyway - some
git tree maintainers do).

> User-Agent: Mozilla-Thunderbird 2.0.0.6 (X11/20071009)

This seems to be setting a record for MUA vandalism.  Leading spaces were
removed and various esoteric whitespace transformations were made.  The
diffs were small so I fixed them by hand.

Please strangle your email client.
