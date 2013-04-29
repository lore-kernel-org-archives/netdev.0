From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [RFC PATCH net-next 0/6] seccomp filter JIT
Date: Mon, 29 Apr 2013 15:21:34 +0200
Message-ID: <517E73DE.7050600@freebox.fr>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com> <20130426112539.GA3736@osiris> <517A6915.2020208@redhat.com> <CAKU6vybdnpoM-szTrJRDVM2sqNPvAe3Tszg+tCuziKSOEXjJ1w@mail.gmail.com> <517E6505.6030005@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mircea Gherzan <mgherzan@gmail.com>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <517E6505.6030005@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/29/2013 02:18 PM, Nicolas Schichan wrote:
> My solution also allows the seccomp jit code to be disabled while still
> allowing jit on socket filters (via a Kconfig option). This might be useful to
> some people.

Please disregard the above, I had missed the fact that the 
BPF_S_ANC_SECCOMP_LD_W case was embedded in an #ifdef CONFIG_SECCOMP_FILTER.

Regards,

-- 
Nicolas Schichan
Freebox SAS
