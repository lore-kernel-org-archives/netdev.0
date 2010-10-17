From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] CAPI: Silence lockdep warning on get_capi_appl_by_nr
 usage
Date: Sun, 17 Oct 2010 12:25:35 +0200
Message-ID: <1287311135.1998.154.camel@laptop>
References: <4CB9891B.4060606@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	i4ldeveloper@listserv.isdn4linux.de,
	Linux Netdev List <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CB9891B.4060606@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-10-16 at 13:14 +0200, Jan Kiszka wrote:
> +       WARN_ON_ONCE(!mutex_is_locked(&capi_controller_lock));

Note there is also lockdep_assert_held() which will actually validate
that the current task is the owner.
